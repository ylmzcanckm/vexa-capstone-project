# VEXA Frontend Integration Guide

## Purpose

This document explains how the Flutter frontend should connect to the VEXA backend API.

The backend is deployed on Render and connected to Supabase PostgreSQL.

---

## Base URLs

Local development:

```text
http://localhost:3000/api
```

Production:

```text
https://vexa-backend-umg2.onrender.com/api
```

For frontend development, the production API can be used directly.

---

## Important Frontend Notes

The backend now uses Supabase PostgreSQL.

This means most entity IDs are UUID values.

Example:

```text
637865ac-af96-4f7f-a133-af4812ff6111
```

The frontend should not use hardcoded mock IDs such as:

```text
user_1
avatar_1
device_1
match_1
```

Instead, the frontend should use IDs returned from API responses.

---

## Authentication Flow

### 1. Register Screen

Endpoint:

```text
POST /auth/register
```

Production URL:

```text
https://vexa-backend-umg2.onrender.com/api/auth/register
```

Request:

```json
{
  "email": "user@example.com",
  "password": "123456",
  "fullName": "User Name"
}
```

Expected use:

```text
Used when the user creates a new account.
```

---

### 2. Login Screen

Endpoint:

```text
POST /auth/login
```

Production URL:

```text
https://vexa-backend-umg2.onrender.com/api/auth/login
```

Request:

```json
{
  "email": "user@example.com",
  "password": "123456"
}
```

Response includes:

```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "fullName": "User Name"
  }
}
```

Frontend responsibility:

```text
Store the JWT token after login.
Send the token in protected API requests.
```

Authorization header format:

```text
Authorization: Bearer jwt_token_here
```

---

## User Profile Flow

### 3. Get Current User

Endpoint:

```text
GET /users/me
```

Production URL:

```text
https://vexa-backend-umg2.onrender.com/api/users/me
```

Headers:

```text
Authorization: Bearer jwt_token_here
```

Expected use:

```text
Used after login to fetch current user data, profile data and settings.
```

If profile or settings are not created yet, they may return as:

```text
null
```

---

### 4. Profile Creation / Edit Screen

Endpoint:

```text
PUT /users/me/profile
```

Production URL:

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
  "personalityTags": ["calm", "curious", "team-oriented"]
}
```

Expected use:

```text
Used when the user creates or updates profile details.
```

Frontend fields can include:

```text
Bio
Interests
Personality tags
```

---

## Avatar Flow

### 5. Avatar Selection Screen - Get Avatars

Endpoint:

```text
GET /avatars
```

Production URL:

```text
https://vexa-backend-umg2.onrender.com/api/avatars
```

Expected use:

```text
Used to display available avatars.
```

The response contains avatar UUID values.

Example:

```json
{
  "id": "637865ac-af96-4f7f-a133-af4812ff6111",
  "name": "Blue Avatar",
  "imageUrl": "https://example.com/avatar1.png"
}
```

Frontend should use the returned `id` when selecting an avatar.

---

### 6. Avatar Selection Screen - Save Selected Avatar

Endpoint:

```text
PUT /users/me/avatar
```

Production URL:

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

Expected use:

```text
Used when the user selects an avatar.
```

Important:

```text
avatarId must come from GET /avatars response.
```

---

## Mode Selection Flow

### 7. Mode Selection Screen

Endpoint:

```text
PUT /users/me/mode
```

Production URL:

```text
https://vexa-backend-umg2.onrender.com/api/users/me/mode
```

Headers:

```text
Authorization: Bearer jwt_token_here
Content-Type: application/json
```

Request for Dating / Social mode:

```json
{
  "mode": "social"
}
```

Request for Networking / Business mode:

```json
{
  "mode": "networking"
}
```

Frontend display labels:

```text
Dating Mode -> backend value: social
Networking Mode -> backend value: networking
```

Expected use:

```text
Used when the user selects the application mode.
```

---

## Device Flow

### 8. Mock Nearby Devices Screen

Endpoint:

```text
GET /devices/mock-nearby
```

Production URL:

```text
https://vexa-backend-umg2.onrender.com/api/devices/mock-nearby
```

Expected use:

```text
Used to simulate nearby VEXA devices before real BLE integration is completed.
```

---

### 9. Device Pairing Screen

Endpoint:

```text
POST /devices/pair
```

Production URL:

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

Expected use:

```text
Used when the user pairs a physical or simulated VEXA device.
```

MVP option:

```text
Until real BLE scanning is ready, the frontend may allow manual device code entry.
```

---

### 10. My Device Screen

Endpoint:

```text
GET /devices/my-device
```

Production URL:

```text
https://vexa-backend-umg2.onrender.com/api/devices/my-device
```

Headers:

```text
Authorization: Bearer jwt_token_here
```

Expected use:

```text
Used to show the currently paired device.
```

If no device is paired:

```json
{
  "success": false,
  "message": "No paired device found"
}
```

---

### 11. Unpair Device

Endpoint:

```text
DELETE /devices/unpair
```

Production URL:

```text
https://vexa-backend-umg2.onrender.com/api/devices/unpair
```

Headers:

```text
Authorization: Bearer jwt_token_here
```

Expected use:

```text
Used when the user removes the paired device.
```

---

## Matching Flow

### 12. Match Candidates Screen

Endpoint:

```text
GET /matches/candidates
```

Production URL:

```text
https://vexa-backend-umg2.onrender.com/api/matches/candidates
```

Headers:

```text
Authorization: Bearer jwt_token_here
```

Expected use:

```text
Used to list possible users for matching.
```

---

### 13. Match Check

Endpoint:

```text
POST /matches/check
```

Production URL:

```text
https://vexa-backend-umg2.onrender.com/api/matches/check
```

Headers:

```text
Authorization: Bearer jwt_token_here
Content-Type: application/json
```

Request by email:

```json
{
  "targetEmail": "target@example.com"
}
```

Alternative request by user ID:

```json
{
  "targetUserId": "uuid"
}
```

Expected use:

```text
Used to calculate compatibility score between two users.
```

Response includes:

```text
matchScore
commonInterests
commonPersonalityTags
sameMode
status
```

---

### 14. Match History Screen

Endpoint:

```text
GET /matches/history
```

Production URL:

```text
https://vexa-backend-umg2.onrender.com/api/matches/history
```

Headers:

```text
Authorization: Bearer jwt_token_here
```

Expected use:

```text
Used to display previous match results.
```

---

## Recommended MVP Screen-to-Endpoint Mapping

```text
Register Screen
-> POST /auth/register

Login Screen
-> POST /auth/login

Home / Session Restore
-> GET /users/me

Profile Setup Screen
-> PUT /users/me/profile

Avatar Selection Screen
-> GET /avatars
-> PUT /users/me/avatar

Mode Selection Screen
-> PUT /users/me/mode

Device Pairing Screen
-> GET /devices/mock-nearby
-> POST /devices/pair
-> GET /devices/my-device
-> DELETE /devices/unpair

Matching Screen
-> GET /matches/candidates
-> POST /matches/check

Match History Screen
-> GET /matches/history
```

---

## Suggested MVP User Journey

```text
1. User registers.
2. User logs in.
3. Frontend stores JWT token.
4. User creates profile.
5. User selects avatar.
6. User selects mode:
   - social
   - networking
7. User pairs a device.
8. User views match candidates.
9. User checks match compatibility.
10. User views match history.
```

---

## Token Handling Reminder

Protected endpoints require this header:

```text
Authorization: Bearer jwt_token_here
```

Protected endpoint groups:

```text
/users/*
/devices/pair
/devices/my-device
/devices/unpair
/matches/*
```

Public endpoint groups:

```text
/health
/db/health
/db/avatars
/avatars
/devices/mock-nearby
/auth/register
/auth/login
```

---

## Render Free Plan Note

The production backend is deployed on Render Free plan.

If the service is inactive for a while, the first request may take longer because the service may wake up from sleep mode.

This is expected behavior.