const express = require("express");

const authMiddleware = require("../middlewares/auth.middleware");
const { devices, devicePairings } = require("../models/memoryStore");

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

router.post("/pair", authMiddleware, (req, res) => {
  const { deviceCode, deviceName, model } = req.body;

  if (!deviceCode) {
    return res.status(400).json({
      success: false,
      message: "deviceCode is required"
    });
  }

  const existingPairing = devicePairings.find(
    (pairing) => pairing.userId === req.user.userId
  );

  if (existingPairing) {
    return res.status(409).json({
      success: false,
      message: "User already has a paired device"
    });
  }

  let device = devices.find((item) => item.deviceCode === deviceCode);

  if (!device) {
    device = {
      id: `device_${devices.length + 1}`,
      deviceCode,
      deviceName: deviceName || "VEXA Device",
      model: model || "LILYGO T-Display S3",
      status: "paired",
      createdAt: new Date().toISOString()
    };

    devices.push(device);
  }

  const pairing = {
    id: `pairing_${devicePairings.length + 1}`,
    userId: req.user.userId,
    deviceId: device.id,
    deviceCode: device.deviceCode,
    pairedAt: new Date().toISOString()
  };

  devicePairings.push(pairing);

  res.status(201).json({
    success: true,
    data: {
      pairing,
      device
    }
  });
});

router.get("/my-device", authMiddleware, (req, res) => {
  const pairing = devicePairings.find(
    (item) => item.userId === req.user.userId
  );

  if (!pairing) {
    return res.status(404).json({
      success: false,
      message: "No paired device found"
    });
  }

  const device = devices.find((item) => item.id === pairing.deviceId);

  res.json({
    success: true,
    data: {
      pairing,
      device
    }
  });
});

router.delete("/unpair", authMiddleware, (req, res) => {
  const pairingIndex = devicePairings.findIndex(
    (item) => item.userId === req.user.userId
  );

  if (pairingIndex === -1) {
    return res.status(404).json({
      success: false,
      message: "No paired device found"
    });
  }

  const removedPairing = devicePairings.splice(pairingIndex, 1)[0];

  res.json({
    success: true,
    message: "Device unpaired successfully",
    data: removedPairing
  });
});

module.exports = router;