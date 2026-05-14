const express = require("express");

const authMiddleware = require("../middlewares/auth.middleware");
const db = require("../config/db");

const router = express.Router();

const mockDevices = [
  {
    deviceId: "vexa_001",
    name: "VEXA Device 001",
    model: "LILYGO T-Display S3",
    chipset: "ESP32-S3R8",
    connectivity: ["WiFi", "BLE"],
    rssi: -55,
    status: "nearby"
  },
  {
    deviceId: "vexa_002",
    name: "VEXA Device 002",
    model: "LILYGO T-Display S3",
    chipset: "ESP32-S3R8",
    connectivity: ["WiFi", "BLE"],
    rssi: -70,
    status: "nearby"
  }
];

router.get("/mock-nearby", (req, res) => {
  res.json({
    success: true,
    data: mockDevices
  });
});

router.post("/pair", authMiddleware, async (req, res) => {
  try {
    const { deviceCode, deviceName, model, chipset, connectivity } = req.body;

    if (!deviceCode) {
      return res.status(400).json({
        success: false,
        message: "deviceCode is required"
      });
    }

    const existingUserPairing = await db.query(
      `SELECT id
       FROM device_pairings
       WHERE user_id = $1 AND status = 'active'`,
      [req.user.userId]
    );

    if (existingUserPairing.rows.length > 0) {
      return res.status(409).json({
        success: false,
        message: "User already has a paired device"
      });
    }

    let deviceResult = await db.query(
      `SELECT *
       FROM devices
       WHERE device_code = $1`,
      [deviceCode]
    );

    let device = deviceResult.rows[0];

    if (!device) {
      deviceResult = await db.query(
        `INSERT INTO devices 
          (device_code, device_name, model, chipset, connectivity, status)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING
          id,
          device_code AS "deviceCode",
          device_name AS "deviceName",
          model,
          chipset,
          connectivity,
          status,
          created_at AS "createdAt",
          updated_at AS "updatedAt"`,
        [
          deviceCode,
          deviceName || "VEXA Device",
          model || "LILYGO T-Display S3",
          chipset || "ESP32-S3R8",
          connectivity || ["WiFi", "BLE"],
          "available"
        ]
      );

      device = deviceResult.rows[0];
    } else {
      device = {
        id: device.id,
        deviceCode: device.device_code,
        deviceName: device.device_name,
        model: device.model,
        chipset: device.chipset,
        connectivity: device.connectivity,
        status: device.status,
        createdAt: device.created_at,
        updatedAt: device.updated_at
      };
    }

    const existingDevicePairing = await db.query(
      `SELECT id
       FROM device_pairings
       WHERE device_id = $1 AND status = 'active'`,
      [device.id]
    );

    if (existingDevicePairing.rows.length > 0) {
      return res.status(409).json({
        success: false,
        message: "Device is already paired with another user"
      });
    }

    const pairingResult = await db.query(
      `INSERT INTO device_pairings (user_id, device_id, status)
       VALUES ($1, $2, 'active')
       RETURNING
        id,
        user_id AS "userId",
        device_id AS "deviceId",
        paired_at AS "pairedAt",
        unpaired_at AS "unpairedAt",
        status,
        created_at AS "createdAt",
        updated_at AS "updatedAt"`,
      [req.user.userId, device.id]
    );

    await db.query(
      `UPDATE devices
       SET status = 'paired', updated_at = CURRENT_TIMESTAMP
       WHERE id = $1`,
      [device.id]
    );

    const updatedDeviceResult = await db.query(
      `SELECT
        id,
        device_code AS "deviceCode",
        device_name AS "deviceName",
        model,
        chipset,
        connectivity,
        status,
        created_at AS "createdAt",
        updated_at AS "updatedAt"
       FROM devices
       WHERE id = $1`,
      [device.id]
    );

    res.status(201).json({
      success: true,
      data: {
        pairing: pairingResult.rows[0],
        device: updatedDeviceResult.rows[0]
      }
    });
  } catch (error) {
    console.error("Device pairing failed:", error);

    res.status(500).json({
      success: false,
      message: "Device pairing failed"
    });
  }
});

router.get("/my-device", authMiddleware, async (req, res) => {
  try {
    const result = await db.query(
      `SELECT
        dp.id AS "pairingId",
        dp.user_id AS "userId",
        dp.device_id AS "deviceId",
        dp.paired_at AS "pairedAt",
        dp.unpaired_at AS "unpairedAt",
        dp.status AS "pairingStatus",
        d.id,
        d.device_code AS "deviceCode",
        d.device_name AS "deviceName",
        d.model,
        d.chipset,
        d.connectivity,
        d.status AS "deviceStatus",
        d.created_at AS "deviceCreatedAt",
        d.updated_at AS "deviceUpdatedAt"
       FROM device_pairings dp
       JOIN devices d ON d.id = dp.device_id
       WHERE dp.user_id = $1 AND dp.status = 'active'
       LIMIT 1`,
      [req.user.userId]
    );

    const row = result.rows[0];

    if (!row) {
      return res.status(404).json({
        success: false,
        message: "No paired device found"
      });
    }

    res.json({
      success: true,
      data: {
        pairing: {
          id: row.pairingId,
          userId: row.userId,
          deviceId: row.deviceId,
          pairedAt: row.pairedAt,
          unpairedAt: row.unpairedAt,
          status: row.pairingStatus
        },
        device: {
          id: row.id,
          deviceCode: row.deviceCode,
          deviceName: row.deviceName,
          model: row.model,
          chipset: row.chipset,
          connectivity: row.connectivity,
          status: row.deviceStatus,
          createdAt: row.deviceCreatedAt,
          updatedAt: row.deviceUpdatedAt
        }
      }
    });
  } catch (error) {
    console.error("Failed to fetch paired device:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch paired device"
    });
  }
});

router.delete("/unpair", authMiddleware, async (req, res) => {
  try {
    const pairingResult = await db.query(
      `SELECT *
       FROM device_pairings
       WHERE user_id = $1 AND status = 'active'
       LIMIT 1`,
      [req.user.userId]
    );

    const pairing = pairingResult.rows[0];

    if (!pairing) {
      return res.status(404).json({
        success: false,
        message: "No paired device found"
      });
    }

    const updatedPairingResult = await db.query(
      `UPDATE device_pairings
       SET
        status = 'inactive',
        unpaired_at = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
       WHERE id = $1
       RETURNING
        id,
        user_id AS "userId",
        device_id AS "deviceId",
        paired_at AS "pairedAt",
        unpaired_at AS "unpairedAt",
        status,
        created_at AS "createdAt",
        updated_at AS "updatedAt"`,
      [pairing.id]
    );

    await db.query(
      `UPDATE devices
       SET status = 'available', updated_at = CURRENT_TIMESTAMP
       WHERE id = $1`,
      [pairing.device_id]
    );

    res.json({
      success: true,
      message: "Device unpaired successfully",
      data: updatedPairingResult.rows[0]
    });
  } catch (error) {
    console.error("Device unpair failed:", error);

    res.status(500).json({
      success: false,
      message: "Device unpair failed"
    });
  }
});

module.exports = router;