# VEXA API Contract

## Base URL

Local development:

```text
http://localhost:3000/api
```

Production:

```text
https://vexa-backend-umg2.onrender.com/api
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

---

## Users

### GET /users/me

Description:

Returns the authenticated user's account information, profile information and user settings. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/users/me
```

Headers:

```text
Authorization: Bearer jwt_token_here
```

Response:

```json
{
  "success": true,
  "data": {
    "id": "user_1",
    "email": "profiletest@example.com",
    "fullName": "Profile Test",
    "profile": null,
    "settings": null
  }
}
```

Note:

If the user has not created profile information or selected avatar/mode yet, `profile` and `settings` will return as `null`.

---

### PUT /users/me/profile

Description:

Creates or updates the authenticated user's profile information. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/users/me/profile
```

Headers:

```text
Authorization: Bearer jwt_token_here
Content-Type: application/json
```

Request:

```json
{
  "bio": "Software engineering student working on VEXA project.",
  "interests": ["technology", "gaming", "networking"],
  "personalityTags": ["calm", "team-oriented", "curious"]
}
```

Response:

```json
{
  "success": true,
  "data": {
    "userId": "user_1",
    "bio": "Software engineering student working on VEXA project.",
    "interests": ["technology", "gaming", "networking"],
    "personalityTags": ["calm", "team-oriented", "curious"],
    "updatedAt": "2026-05-13T00:00:00.000Z"
  }
}
```

---

### PUT /users/me/avatar

Description:

Updates the authenticated user's selected avatar. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/users/me/avatar
```

Headers:

```text
Authorization: Bearer jwt_token_here
Content-Type: application/json
```

Request:

```json
{
  "avatarId": "avatar_1"
}
```

Response:

```json
{
  "success": true,
  "data": {
    "userId": "user_1",
    "selectedAvatarId": "avatar_1",
    "selectedMode": null,
    "isAvailable": true,
    "updatedAt": "2026-05-13T00:00:00.000Z"
  }
}
```

Possible Error:

```json
{
  "success": false,
  "message": "avatarId is required"
}
```

---

### PUT /users/me/mode

Description:

Updates the authenticated user's selected mode. The mode must be either `social` or `networking`. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/users/me/mode
```

Headers:

```text
Authorization: Bearer jwt_token_here
Content-Type: application/json
```

Request:

```json
{
  "mode": "networking"
}
```

Response:

```json
{
  "success": true,
  "data": {
    "userId": "user_1",
    "selectedAvatarId": "avatar_1",
    "selectedMode": "networking",
    "isAvailable": true,
    "updatedAt": "2026-05-13T00:00:00.000Z"
  }
}
```

Possible Error:

```json
{
  "success": false,
  "message": "mode must be either social or networking"
}
```

---

## Development Notes

The current backend uses an in-memory temporary store for users, profiles and settings. This means data will be deleted when the backend server restarts. A real database will be added later.

---

## Device Pairing

### POST /devices/pair

Description:

Pairs the authenticated user with a VEXA device. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/devices/pair
```

Headers:

```text
Authorization: Bearer jwt_token_here
Content-Type: application/json
```

Request:

```json
{
  "deviceCode": "XY251108-H569-001",
  "deviceName": "VEXA T-Display S3 001",
  "model": "LILYGO T-Display S3"
}
```

Response:

```json
{
  "success": true,
  "data": {
    "pairing": {
      "id": "pairing_1",
      "userId": "user_1",
      "deviceId": "device_1",
      "deviceCode": "XY251108-H569-001",
      "pairedAt": "2026-05-13T00:00:00.000Z"
    },
    "device": {
      "id": "device_1",
      "deviceCode": "XY251108-H569-001",
      "deviceName": "VEXA T-Display S3 001",
      "model": "LILYGO T-Display S3",
      "status": "paired",
      "createdAt": "2026-05-13T00:00:00.000Z"
    }
  }
}
```

Possible Errors:

```json
{
  "success": false,
  "message": "deviceCode is required"
}
```

```json
{
  "success": false,
  "message": "User already has a paired device"
}
```

---

### GET /devices/my-device

Description:

Returns the authenticated user's paired device. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/devices/my-device
```

Headers:

```text
Authorization: Bearer jwt_token_here
```

Response:

```json
{
  "success": true,
  "data": {
    "pairing": {
      "id": "pairing_1",
      "userId": "user_1",
      "deviceId": "device_1",
      "deviceCode": "XY251108-H569-001",
      "pairedAt": "2026-05-13T00:00:00.000Z"
    },
    "device": {
      "id": "device_1",
      "deviceCode": "XY251108-H569-001",
      "deviceName": "VEXA T-Display S3 001",
      "model": "LILYGO T-Display S3",
      "status": "paired",
      "createdAt": "2026-05-13T00:00:00.000Z"
    }
  }
}
```

Possible Error:

```json
{
  "success": false,
  "message": "No paired device found"
}
```

---

### DELETE /devices/unpair

Description:

Removes the authenticated user's paired device connection. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/devices/unpair
```

Headers:

```text
Authorization: Bearer jwt_token_here
```

Response:

```json
{
  "success": true,
  "message": "Device unpaired successfully",
  "data": {
    "id": "pairing_1",
    "userId": "user_1",
    "deviceId": "device_1",
    "deviceCode": "XY251108-H569-001",
    "pairedAt": "2026-05-13T00:00:00.000Z"
  }
}
```

Possible Error:

```json
{
  "success": false,
  "message": "No paired device found"
}
```

Note:

The current device pairing system uses an in-memory temporary store. Pairing data will be deleted when the backend server restarts. A real database will be added later.

---

## Matches

### GET /matches/candidates

Description:

Returns possible match candidates for the authenticated user. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/matches/candidates
```

Headers:

```text
Authorization: Bearer jwt_token_here
```

Response:

```json
{
  "success": true,
  "data": [
    {
      "id": "user_2",
      "email": "matchb@example.com",
      "fullName": "Match User B",
      "profile": {
        "userId": "user_2",
        "bio": "User B profile for matching test.",
        "interests": ["technology", "music", "networking"],
        "personalityTags": ["curious", "creative"],
        "updatedAt": "2026-05-13T00:00:00.000Z"
      },
      "settings": {
        "userId": "user_2",
        "selectedAvatarId": null,
        "selectedMode": "networking",
        "isAvailable": true,
        "updatedAt": "2026-05-13T00:00:00.000Z"
      }
    }
  ]
}
```

---

### POST /matches/check

Description:

Checks the match compatibility between the authenticated user and a target user. The target user can be selected by `targetUserId` or `targetEmail`.

Full local URL:

```text
http://localhost:3000/api/matches/check
```

Headers:

```text
Authorization: Bearer jwt_token_here
Content-Type: application/json
```

Request:

```json
{
  "targetEmail": "matchb@example.com"
}
```

Alternative Request:

```json
{
  "targetUserId": "user_2"
}
```

Response:

```json
{
  "success": true,
  "data": {
    "id": "match_1",
    "userId1": "user_1",
    "userId2": "user_2",
    "matchScore": 85,
    "commonInterests": ["technology", "networking"],
    "commonPersonalityTags": ["curious"],
    "sameMode": true,
    "mode": "networking",
    "status": "detected",
    "createdAt": "2026-05-13T00:00:00.000Z",
    "updatedAt": "2026-05-13T00:00:00.000Z"
  }
}
```

Possible Errors:

```json
{
  "success": false,
  "message": "Current user not found"
}
```

```json
{
  "success": false,
  "message": "Target user not found"
}
```

```json
{
  "success": false,
  "message": "User cannot match with themselves"
}
```

---

### GET /matches/history

Description:

Returns the authenticated user's match history. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/matches/history
```

Headers:

```text
Authorization: Bearer jwt_token_here
```

Response:

```json
{
  "success": true,
  "data": [
    {
      "id": "match_1",
      "userId1": "user_1",
      "userId2": "user_2",
      "matchScore": 85,
      "commonInterests": ["technology", "networking"],
      "commonPersonalityTags": ["curious"],
      "sameMode": true,
      "mode": "networking",
      "status": "detected",
      "createdAt": "2026-05-13T00:00:00.000Z",
      "updatedAt": "2026-05-13T00:00:00.000Z",
      "otherUser": {
        "id": "user_2",
        "email": "matchb@example.com",
        "fullName": "Match User B"
      }
    }
  ]
}
```

---

## Matching Score Logic

The current matching score is calculated with the following temporary logic:

```text
Each common interest: +25 points
Each common personality tag: +15 points
Same selected mode: +20 points
Maximum score: 100
Match threshold: 50
```

Example:

```text
Common interests: technology, networking = 50 points
Common personality tags: curious = 15 points
Same mode: networking = 20 points
Total score: 85
```

If the score is 50 or higher, the match status becomes:

```text
detected
```

If the score is below 50, the match status becomes:

```text
not_matched
```

Note:

This matching logic is temporary and will be improved later based on real project requirements, user profiles and BLE proximity data.