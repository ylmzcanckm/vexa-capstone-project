# VEXA API Contract

## Base URL

Local development:

```text
http://localhost:3000/api
```

---

## Health Check

### GET /health

Description:

Checks whether the backend server is running.

Full local URL:

```text
http://localhost:3000/api/health
```

Response:

```json
{
  "success": true,
  "message": "VEXA backend is running"
}
```

---

## Avatars

### GET /avatars

Description:

Returns the list of available avatar options. This endpoint currently returns mock avatar data for frontend development.

Full local URL:

```text
http://localhost:3000/api/avatars
```

Response:

```json
{
  "success": true,
  "data": [
    {
      "id": "avatar_1",
      "name": "Blue Avatar",
      "imageUrl": "https://example.com/avatar1.png"
    },
    {
      "id": "avatar_2",
      "name": "Green Avatar",
      "imageUrl": "https://example.com/avatar2.png"
    },
    {
      "id": "avatar_3",
      "name": "Purple Avatar",
      "imageUrl": "https://example.com/avatar3.png"
    }
  ]
}
```

Note:

The image URLs are temporary placeholders. Real avatar assets will be added later.

---

## Devices

### GET /devices/mock-nearby

Description:

Returns a mock list of nearby VEXA devices. This endpoint is used because the physical devices are not available yet.

Full local URL:

```text
http://localhost:3000/api/devices/mock-nearby
```

Response:

```json
{
  "success": true,
  "data": [
    {
      "deviceId": "vexa_001",
      "name": "VEXA Device 001",
      "rssi": -55,
      "status": "nearby"
    },
    {
      "deviceId": "vexa_002",
      "name": "VEXA Device 002",
      "rssi": -70,
      "status": "nearby"
    }
  ]
}
```

Note:

This endpoint simulates nearby devices for frontend testing. It will later be replaced or extended with real BLE/device integration logic.

---

## Auth

### POST /auth/register

Description:

Creates a new user account. This endpoint currently stores users in memory for development purposes. Data will be lost when the backend server restarts.

Full local URL:

```text
http://localhost:3000/api/auth/register
```

Request:

```json
{
  "email": "can@example.com",
  "password": "123456",
  "fullName": "Can"
}
```

Response:

```json
{
  "success": true,
  "data": {
    "id": "user_1",
    "email": "can@example.com",
    "fullName": "Can"
  }
}
```

Possible Errors:

```json
{
  "success": false,
  "message": "Email, password and fullName are required"
}
```

```json
{
  "success": false,
  "message": "Email already exists"
}
```

---

### POST /auth/login

Description:

Logs in an existing user and returns a JWT token.

Full local URL:

```text
http://localhost:3000/api/auth/login
```

Request:

```json
{
  "email": "can@example.com",
  "password": "123456"
}
```

Response:

```json
{
  "success": true,
  "data": {
    "token": "jwt_token_here",
    "user": {
      "id": "user_1",
      "email": "can@example.com",
      "fullName": "Can"
    }
  }
}
```

Possible Errors:

```json
{
  "success": false,
  "message": "Email and password are required"
}
```

```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

Note:

The token will be used later for protected user-specific endpoints such as profile, selected avatar, selected mode and match history.