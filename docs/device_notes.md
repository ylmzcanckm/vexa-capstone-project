# VEXA Device Notes

## Current Device Information

The physical devices received for the VEXA project appear to be LILYGO T-Display S3 modules.

Visible information from the device packaging:

```text
Brand: LILYGO
Model: T-Display S3
Chip: ESP32-S3R8
Connectivity: WiFi + BLE
Display: 1.9 inch 8-bit LCD
```

## Current Status

The devices are physically available to the team, but BLE scanning and connection tests have not been performed yet.

## Planned BLE Investigation

The following information must be collected later using a BLE scanner application such as nRF Connect:

```text
1. Advertised Bluetooth device name
2. MAC address or device identifier
3. Service UUIDs
4. Characteristic UUIDs
5. Readable characteristics
6. Writable characteristics
7. Notification characteristics
8. Whether the device accepts write commands
9. Whether the screen can be updated through BLE
10. Whether vibration, LED or sound feedback exists
```

## Expected System Flow

```text
VEXA Device <-> Mobile App <-> Backend
```

## Backend Responsibility

```text
1. Storing which user is paired with which device
2. Returning the authenticated user's paired device
3. Saving selected avatar and mode
4. Supporting match history later
5. Supporting device-related logs later
```

## Frontend Responsibility

```text
1. Scanning nearby BLE devices
2. Connecting to the selected VEXA device
3. Sending selected avatar and mode information to the device
4. Receiving BLE signals from the device
5. Sending necessary interaction data to the backend
```

## Important Note

Real BLE integration will be implemented after the device's BLE services and characteristics are identified.