# VEXA MVP Backend Checklist

## Purpose

This document tracks the backend status for the VEXA MVP.

The goal of the MVP is not to build a fully production-ready product. The goal is to create a working demo flow that supports the main user journey:

```text
Register
Login
Create profile
Select avatar
Select mode
Pair device
Check match compatibility
View match history
```

---

## Current Backend Status

The backend is deployed and connected to a real database.

```text
Production API: https://vexa-backend-umg2.onrender.com/api
Database: Supabase PostgreSQL
Deployment: Render
```

---

## Completed Backend Modules

### 1. Project Setup

```text
Node.js / Express backend created
GitHub repo structure created
Backend and frontend folders separated
Docs folder created
Branch workflow established
```

Status:

```text
Completed
```

---

### 2. Authentication

Implemented endpoints:

```text
POST /auth/register
POST /auth/login
```

Features:

```text
User registration
Password hashing with bcryptjs
User login
JWT token generation
Supabase users table integration
```

Status:

```text
Completed
```

---

### 3. User Profile and Settings

Implemented endpoints:

```text
GET /users/me
PUT /users/me/profile
PUT /users/me/avatar
PUT /users/me/mode
```

Features:

```text
Fetch authenticated user
Create/update profile
Save interests
Save personality tags
Select avatar
Select mode
Store user settings in database
```

Supported mode values:

```text
social
networking
```

Frontend labels:

```text
Dating / Social Mode -> social
Networking / Business Mode -> networking
```

Status:

```text
Completed
```

---

### 4. Avatar System

Implemented endpoint:

```text
GET /avatars
```

Features:

```text
Fetch avatar list from Supabase PostgreSQL
Return UUID-based avatar IDs
Return avatar name and image URL
```

Important frontend note:

```text
Frontend must use avatar IDs returned from GET /avatars.
Hardcoded values such as avatar_1 should not be used.
```

Status:

```text
Completed
```

---

### 5. Device Pairing

Implemented endpoints:

```text
GET /devices/mock-nearby
POST /devices/pair
GET /devices/my-device
DELETE /devices/unpair
```

Features:

```text
Return mock nearby devices
Pair authenticated user with a device
Fetch authenticated user's paired device
Unpair device
Store device and pairing information in Supabase PostgreSQL
Update device status as paired or available
```

Status:

```text
Completed for MVP
```

Note:

```text
Real BLE scanning is not handled by the backend.
The expected architecture is: Device <-> Flutter App <-> Backend.
```

---

### 6. Matching System

Implemented endpoints:

```text
GET /matches/candidates
POST /matches/check
GET /matches/history
```

Features:

```text
Fetch possible match candidates
Calculate match score
Store match records in Supabase PostgreSQL
Store match history
Return previous match results
```

Current temporary matching logic:

```text
Each common interest: +25 points
Each common personality tag: +15 points
Same selected mode: +20 points
Maximum score: 100
Match threshold: 50
```

Status:

```text
Completed for MVP
```

Note:

```text
The matching logic is temporary and can be improved later with real BLE proximity data and more detailed user profile attributes.
```

---

### 7. Database

Database provider:

```text
Supabase PostgreSQL
```

Created tables:

```text
users
profiles
avatars
user_settings
devices
device_pairings
matches
match_history
```

Status:

```text
Completed
```

---

### 8. Deployment

Deployment provider:

```text
Render
```

Production backend URL:

```text
https://vexa-backend-umg2.onrender.com/api
```

Configured environment variables:

```text
JWT_SECRET
DATABASE_URL
```

Status:

```text
Completed
```

---

### 9. Documentation

Created and updated documents:

```text
docs/api_contract.md
docs/database_schema.md
docs/device_notes.md
docs/frontend_integration_guide.md
README.md
```

Status:

```text
Completed
```

---

## MVP Backend Remaining Tasks

The following tasks are not required for the backend to function, but they should be reviewed before the final MVP demo.

### 1. Frontend Integration Support

Task:

```text
Support Selçuk while connecting the Flutter app to the production API.
```

Expected possible fixes:

```text
CORS issues
Token handling issues
Response format adjustments
Missing frontend-friendly fields
Small endpoint improvements
```

Priority:

```text
High
```

Status:

```text
Pending frontend integration
```

---

### 2. Final API Testing

Task:

```text
Test the full MVP flow on production.
```

Test flow:

```text
1. Register user A
2. Login user A
3. Create profile for user A
4. Select avatar for user A
5. Select mode for user A
6. Pair device for user A
7. Register user B
8. Login user B
9. Create profile for user B
10. Select mode for user B
11. Check match between user A and user B
12. View match history
```

Priority:

```text
High
```

Status:

```text
Partially completed
```

---

### 3. Device Technical Discovery

Task:

```text
Inspect physical LILYGO T-Display S3 devices.
```

Checklist:

```text
Check USB connection
Check device power status
Check if Mac detects the board
Check if Arduino IDE or PlatformIO detects the board
Check if device has existing firmware
Check screen test
Check BLE advertising
Check nRF Connect visibility
Collect service UUIDs
Collect characteristic UUIDs
```

Priority:

```text
High
```

Status:

```text
Pending physical device access
```

---

### 4. BLE Integration Planning

Task:

```text
Decide how the Flutter app will communicate with the device through BLE.
```

Expected flow:

```text
Device <-> Flutter App <-> Backend
```

Backend responsibility:

```text
Store user-device pairing
Store user profile and mode
Store match records
Store device-related events if needed
```

Frontend responsibility:

```text
Scan BLE devices
Connect to selected device
Read/write BLE characteristics
Send necessary data to backend
```

Priority:

```text
Medium
```

Status:

```text
Pending device discovery
```

---

### 5. Optional Device Event Endpoint

Possible future endpoint:

```text
POST /devices/events
```

Possible use:

```text
Store device-related events such as proximity detected, notification triggered, device connected or device disconnected.
```

Priority:

```text
Optional for MVP
```

Status:

```text
Not started
```

---

## MVP Demo Scenario

The suggested demo flow is:

```text
1. Open Flutter app
2. Register or login
3. Create user profile
4. Select avatar
5. Select Dating/Social or Networking mode
6. Pair a VEXA device using manual device code or mock device list
7. Create or use a second test user
8. Run match compatibility check
9. Show match score and common interests
10. Show match history
```

---

## Backend MVP Completion Estimate

Current MVP backend completion:

```text
Approximately 85% - 90%
```

Remaining backend effort:

```text
Frontend integration support
Final production testing
Small adjustments based on frontend needs
Device-related optional endpoint if needed
```

Estimated time to MVP-ready backend:

```text
1 - 2 focused working days
```

---

## Important Notes

```text
The backend is suitable for MVP and demo purposes.
The backend is not yet a fully production-grade commercial backend.
Security, validation, test coverage and advanced BLE-driven logic can be improved after the MVP phase.
```