const express = require("express");

const router = express.Router();

const mockDevices = [
  {
    deviceId: "vexa_001",
    name: "VEXA Device 001",
    rssi: -55,
    status: "nearby"
  },
  {
    deviceId: "vexa_002",
    name: "VEXA Device 002",
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

module.exports = router;