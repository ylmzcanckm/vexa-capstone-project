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

## Backend Data Storage Note

The backend now uses Supabase PostgreSQL for persistent data storage.

The following modules are database-backed:

```text
Auth
Users
Profiles
User settings
Avatars
Device pairings
Matches
Match history
```

Important:

```text
Most entity IDs are now UUID values.
```

Example UUID:

```text
637865ac-af96-4f7f-a133-af4812ff6111
```

This means frontend requests should use the actual IDs returned from the API instead of hardcoded mock IDs such as `user_1`, `avatar_1`, `device_1`, `pairing_1` or `match_1`.

Temporary database test endpoints:

```text
GET /api/db/health
GET /api/db/avatars
```

These endpoints are used only for checking database connectivity.

---

## Health Check

### GET /health

Description:

Checks whether the backend server is running.

Full local URL:

```text
http://localhost:3000/api/health
```

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/health
```

Response:

```json
{
  "success": true,
  "message": "VEXA backend is running"
}
```

---

## Database Health Check

### GET /db/health

Description:

Checks whether the backend can connect to Supabase PostgreSQL.

Full local URL:

```text
http://localhost:3000/api/db/health
```

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/db/health
```

Response:

```json
{
  "success": true,
  "message": "Database connection is working",
  "data": {
    "current_time": "2026-05-14T12:14:35.711Z"
  }
}
```

---

### GET /db/avatars

Description:

Returns avatar records directly from the database. This endpoint is mainly used for testing database connectivity.

Full local URL:

```text
http://localhost:3000/api/db/avatars
```

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/db/avatars
```

Response:

```json
{
  "success": true,
  "data": [
    {
      "id": "637865ac-af96-4f7f-a133-af4812ff6111",
      "name": "Blue Avatar",
      "imageUrl": "https://example.com/avatar1.png",
      "createdAt": "2026-05-13T17:16:04.169Z",
      "updatedAt": "2026-05-13T17:16:04.169Z"
    }
  ]
}
```

---

## Avatars

### GET /avatars

Description:

Returns the list of available avatar options from Supabase PostgreSQL.

Full local URL:

```text
http://localhost:3000/api/avatars
```

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/avatars
```

Response:

```json
{
  "success": true,
  "data": [
    {
      "id": "637865ac-af96-4f7f-a133-af4812ff6111",
      "name": "Blue Avatar",
      "imageUrl": "https://example.com/avatar1.png",
      "createdAt": "2026-05-13T17:16:04.169Z",
      "updatedAt": "2026-05-13T17:16:04.169Z"
    },
    {
      "id": "e4c21845-23c2-45cb-a02e-846885aa0a69",
      "name": "Green Avatar",
      "imageUrl": "https://example.com/avatar2.png",
      "createdAt": "2026-05-13T17:16:04.169Z",
      "updatedAt": "2026-05-13T17:16:04.169Z"
    },
    {
      "id": "c32c9f01-4f64-4b70-96bd-37f459dbcb09",
      "name": "Purple Avatar",
      "imageUrl": "https://example.com/avatar3.png",
      "createdAt": "2026-05-13T17:16:04.169Z",
      "updatedAt": "2026-05-13T17:16:04.169Z"
    }
  ]
}
```

Note:

The image URLs are temporary placeholders. Real avatar assets will be added later.

Important:

Frontend should use the `id` values returned from this endpoint when selecting an avatar. Do not hardcode values such as `avatar_1`.

---

## Auth

### POST /auth/register

Description:

Creates a new user account and stores the user in Supabase PostgreSQL.

Full local URL:

```text
http://localhost:3000/api/auth/register
```

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/auth/register
```

Request:

```json
{
  "email": "can@example.com",
  "password": "<DEMO_PASSWORD>",
  "fullName": "Can"
}
```

Response:

```json
{
  "success": true,
  "data": {
    "id": "e2d8399d-7fb1-4496-86c7-fd2144d5ffcf",
    "email": "can@example.com",
    "fullName": "Can",
    "createdAt": "2026-05-14T12:35:14.342Z"
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

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/auth/login
```

Request:

```json
{
  "email": "can@example.com",
  "password": "<DEMO_PASSWORD>"
}
```

Response:

```json
{
  "success": true,
  "data": {
    "token": "jwt_token_here",
    "user": {
      "id": "e2d8399d-7fb1-4496-86c7-fd2144d5ffcf",
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

The token must be sent in the `Authorization` header for protected endpoints.

Example:

```text
Authorization: Bearer jwt_token_here
```

---

## Users

### GET /users/me

Description:

Returns the authenticated user's account information, profile information and user settings. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/users/me
```

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/users/me
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
    "id": "e2d8399d-7fb1-4496-86c7-fd2144d5ffcf",
    "email": "profiletest@example.com",
    "fullName": "Profile Test",
    "createdAt": "2026-05-14T12:35:14.342Z",
    "updatedAt": "2026-05-14T12:35:14.342Z",
    "profile": {
      "userId": "e2d8399d-7fb1-4496-86c7-fd2144d5ffcf",
      "bio": "Production database connected VEXA user.",
      "interests": ["technology", "gaming", "networking"],
      "personalityTags": ["calm", "curious", "team-oriented"],
      "createdAt": "2026-05-14T12:36:10.000Z",
      "updatedAt": "2026-05-14T12:36:10.000Z"
    },
    "settings": {
      "userId": "e2d8399d-7fb1-4496-86c7-fd2144d5ffcf",
      "selectedAvatarId": "637865ac-af96-4f7f-a133-af4812ff6111",
      "selectedMode": "networking",
      "isAvailable": true,
      "createdAt": "2026-05-14T12:36:42.000Z",
      "updatedAt": "2026-05-14T12:37:10.000Z"
    }
  }
}
```

Possible Error:

```json
{
  "success": false,
  "message": "Authorization header is required"
}
```

Note:

If the user has not created profile information or selected avatar/mode yet, `profile` and `settings` will return as `null`.

---

### PUT /users/me/profile

Description:

Creates or updates the authenticated user's profile information in Supabase PostgreSQL. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/users/me/profile
```

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/users/me/profile
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
    "userId": "e2d8399d-7fb1-4496-86c7-fd2144d5ffcf",
    "bio": "Software engineering student working on VEXA project.",
    "interests": ["technology", "gaming", "networking"],
    "personalityTags": ["calm", "team-oriented", "curious"],
    "createdAt": "2026-05-14T12:36:10.000Z",
    "updatedAt": "2026-05-14T12:36:10.000Z"
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

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/users/me/avatar
```

Headers:

```text
Authorization: Bearer jwt_token_here
Content-Type: application/json
```

Request:

```json
{
  "avatarId": "637865ac-af96-4f7f-a133-af4812ff6111"
}
```

Response:

```json
{
  "success": true,
  "data": {
    "userId": "e2d8399d-7fb1-4496-86c7-fd2144d5ffcf",
    "selectedAvatarId": "637865ac-af96-4f7f-a133-af4812ff6111",
    "selectedMode": null,
    "isAvailable": true,
    "createdAt": "2026-05-14T12:36:42.000Z",
    "updatedAt": "2026-05-14T12:36:42.000Z"
  }
}
```

Possible Errors:

```json
{
  "success": false,
  "message": "avatarId is required"
}
```

```json
{
  "success": false,
  "message": "Avatar not found"
}
```

Important:

The `avatarId` value must be one of the UUID values returned from `GET /avatars`.

---

### PUT /users/me/mode

Description:

Updates the authenticated user's selected mode. The mode must be either `social` or `networking`. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/users/me/mode
```

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/users/me/mode
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
    "userId": "e2d8399d-7fb1-4496-86c7-fd2144d5ffcf",
    "selectedAvatarId": "637865ac-af96-4f7f-a133-af4812ff6111",
    "selectedMode": "networking",
    "isAvailable": true,
    "createdAt": "2026-05-14T12:36:42.000Z",
    "updatedAt": "2026-05-14T12:37:10.000Z"
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

Note:

Frontend may display this as Dating/Social Mode and Networking/Business Mode. Backend currently stores the values as:

```text
social
networking
```

---

## Devices

### GET /devices/mock-nearby

Description:

Returns a mock list of nearby VEXA devices. This endpoint is used to simulate nearby BLE devices for frontend testing.

Full local URL:

```text
http://localhost:3000/api/devices/mock-nearby
```

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/devices/mock-nearby
```

Response:

```json
{
  "success": true,
  "data": [
    {
      "deviceId": "vexa_001",
      "name": "VEXA Device 001",
      "model": "LILYGO T-Display S3",
      "chipset": "ESP32-S3R8",
      "connectivity": ["WiFi", "BLE"],
      "rssi": -55,
      "status": "nearby"
    },
    {
      "deviceId": "vexa_002",
      "name": "VEXA Device 002",
      "model": "LILYGO T-Display S3",
      "chipset": "ESP32-S3R8",
      "connectivity": ["WiFi", "BLE"],
      "rssi": -70,
      "status": "nearby"
    }
  ]
}
```

Note:

This endpoint simulates nearby devices for frontend testing. It can later be replaced or extended with real BLE/device integration logic.

---

## Device Pairing

### POST /devices/pair

Description:

Pairs the authenticated user with a VEXA device and stores the pairing in Supabase PostgreSQL. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/devices/pair
```

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/devices/pair
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
  "model": "LILYGO T-Display S3",
  "chipset": "ESP32-S3R8",
  "connectivity": ["WiFi", "BLE"]
}
```

Response:

```json
{
  "success": true,
  "data": {
    "pairing": {
      "id": "10f55923-ce86-42b3-b221-7a54a3dcc072",
      "userId": "e2d8399d-7fb1-4496-86c7-fd2144d5ffcf",
      "deviceId": "484b8c8d-f431-4d96-a693-c32f7e5aa705",
      "pairedAt": "2026-05-14T12:49:25.953Z",
      "unpairedAt": null,
      "status": "active",
      "createdAt": "2026-05-14T12:49:25.953Z",
      "updatedAt": "2026-05-14T12:49:25.953Z"
    },
    "device": {
      "id": "484b8c8d-f431-4d96-a693-c32f7e5aa705",
      "deviceCode": "XY251108-H569-001",
      "deviceName": "VEXA T-Display S3 001",
      "model": "LILYGO T-Display S3",
      "chipset": "ESP32-S3R8",
      "connectivity": ["WiFi", "BLE"],
      "status": "paired",
      "createdAt": "2026-05-14T12:49:25.711Z",
      "updatedAt": "2026-05-14T12:49:26.074Z"
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

```json
{
  "success": false,
  "message": "Device is already paired with another user"
}
```

---

### GET /devices/my-device

Description:

Returns the authenticated user's active paired device. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/devices/my-device
```

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/devices/my-device
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
      "id": "10f55923-ce86-42b3-b221-7a54a3dcc072",
      "userId": "e2d8399d-7fb1-4496-86c7-fd2144d5ffcf",
      "deviceId": "484b8c8d-f431-4d96-a693-c32f7e5aa705",
      "pairedAt": "2026-05-14T12:49:25.953Z",
      "unpairedAt": null,
      "status": "active"
    },
    "device": {
      "id": "484b8c8d-f431-4d96-a693-c32f7e5aa705",
      "deviceCode": "XY251108-H569-001",
      "deviceName": "VEXA T-Display S3 001",
      "model": "LILYGO T-Display S3",
      "chipset": "ESP32-S3R8",
      "connectivity": ["WiFi", "BLE"],
      "status": "paired",
      "createdAt": "2026-05-14T12:49:25.711Z",
      "updatedAt": "2026-05-14T12:49:26.074Z"
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

Removes the authenticated user's active device pairing by marking the pairing as inactive and setting the device status back to available. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/devices/unpair
```

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/devices/unpair
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
    "id": "10f55923-ce86-42b3-b221-7a54a3dcc072",
    "userId": "e2d8399d-7fb1-4496-86c7-fd2144d5ffcf",
    "deviceId": "484b8c8d-f431-4d96-a693-c32f7e5aa705",
    "pairedAt": "2026-05-14T12:49:25.953Z",
    "unpairedAt": "2026-05-14T12:49:55.723Z",
    "status": "inactive",
    "createdAt": "2026-05-14T12:49:25.953Z",
    "updatedAt": "2026-05-14T12:49:55.723Z"
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

## Matches

### GET /matches/candidates

Description:

Returns possible match candidates for the authenticated user. This endpoint reads users, profiles and user settings from Supabase PostgreSQL. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/matches/candidates
```

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/matches/candidates
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
      "id": "21052e92-f680-4079-b551-4c1ab7ac3359",
      "email": "prod-matchb@example.com",
      "fullName": "Production Match User B",
      "profile": {
        "bio": "Production second match user.",
        "interests": ["technology", "music", "networking"],
        "personalityTags": ["curious", "creative"]
      },
      "settings": {
        "selectedAvatarId": null,
        "selectedMode": "networking",
        "isAvailable": true
      }
    }
  ]
}
```

---

### POST /matches/check

Description:

Checks the match compatibility between the authenticated user and a target user. The target user can be selected by `targetUserId` or `targetEmail`. Match results are stored in Supabase PostgreSQL.

Full local URL:

```text
http://localhost:3000/api/matches/check
```

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/matches/check
```

Headers:

```text
Authorization: Bearer jwt_token_here
Content-Type: application/json
```

Request:

```json
{
  "targetEmail": "prod-matchb@example.com"
}
```

Alternative Request:

```json
{
  "targetUserId": "21052e92-f680-4079-b551-4c1ab7ac3359"
}
```

Response:

```json
{
  "success": true,
  "data": {
    "id": "da04f704-698a-4811-84bf-e9fa7080036e",
    "userId1": "e2d8399d-7fb1-4496-86c7-fd2144d5ffcf",
    "userId2": "21052e92-f680-4079-b551-4c1ab7ac3359",
    "matchScore": 85,
    "commonInterests": ["technology", "networking"],
    "commonPersonalityTags": ["curious"],
    "sameMode": true,
    "mode": "networking",
    "status": "detected",
    "createdAt": "2026-05-14T13:19:12.079Z",
    "updatedAt": "2026-05-14T13:19:12.079Z"
  }
}
```

Possible Errors:

```json
{
  "success": false,
  "message": "targetUserId or targetEmail is required"
}
```

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

Returns the authenticated user's match history from Supabase PostgreSQL. This endpoint requires a valid JWT token.

Full local URL:

```text
http://localhost:3000/api/matches/history
```

Full production URL:

```text
https://vexa-backend-umg2.onrender.com/api/matches/history
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
      "id": "da04f704-698a-4811-84bf-e9fa7080036e",
      "userId1": "e2d8399d-7fb1-4496-86c7-fd2144d5ffcf",
      "userId2": "21052e92-f680-4079-b551-4c1ab7ac3359",
      "matchScore": 85,
      "commonInterests": ["technology", "networking"],
      "commonPersonalityTags": ["curious"],
      "sameMode": true,
      "mode": "networking",
      "status": "detected",
      "createdAt": "2026-05-14T13:19:12.079Z",
      "updatedAt": "2026-05-14T13:19:12.079Z",
      "otherUser": {
        "id": "21052e92-f680-4079-b551-4c1ab7ac3359",
        "email": "prod-matchb@example.com",
        "fullName": "Production Match User B"
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

---

## Environment Variables

The backend requires the following environment variables:

```text
JWT_SECRET
DATABASE_URL
```

Local development:

```text
backend/.env
```

Production:

```text
Render Environment Variables
```

Important:

Do not commit real `.env` values, JWT secrets or database connection strings to GitHub.