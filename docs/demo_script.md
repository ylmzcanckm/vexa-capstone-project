# VEXA MVP Demo Script

## Purpose

This document defines the suggested MVP demo flow for the VEXA project.

The purpose of the demo is to show that the main system flow works from user registration to profile setup, device pairing and match calculation.

The MVP does not aim to represent a fully commercial product. It aims to demonstrate the working core logic of the VEXA system.

---

## Demo Environment

Production API:

```text
https://vexa-backend-umg2.onrender.com/api
```

Backend deployment:

```text
Render
```

Database:

```text
Supabase PostgreSQL
```

Frontend:

```text
Flutter mobile application
```

Device:

```text
LILYGO T-Display S3
```

Current device integration status:

```text
The backend supports device pairing.
Real BLE discovery and device communication will be tested separately when the physical device is available.
```

---

## Main MVP Demo Flow

The suggested demo flow is:

```text
1. User registers
2. User logs in
3. User creates profile
4. User selects avatar
5. User selects mode
6. User pairs a VEXA device
7. Second user is created or selected
8. Match compatibility is calculated
9. Match history is displayed
```

---

## Step 1: Register User

### Screen

```text
Register Screen
```

### Backend Endpoint

```text
POST /auth/register
```

### Demo Explanation

The user creates a new VEXA account by entering:

```text
Full name
Email
Password
```

### Expected Result

```text
The user account is created and stored in Supabase PostgreSQL.
```

---

## Step 2: Login User

### Screen

```text
Login Screen
```

### Backend Endpoint

```text
POST /auth/login
```

### Demo Explanation

The user logs into the application with email and password.

### Expected Result

```text
The backend returns a JWT token.
The frontend stores this token and uses it for protected requests.
```

---

## Step 3: Create User Profile

### Screen

```text
Profile Setup Screen
```

### Backend Endpoint

```text
PUT /users/me/profile
```

### Demo Explanation

The user enters profile information such as:

```text
Bio
Interests
Personality tags
```

Example interests:

```text
technology
gaming
networking
```

Example personality tags:

```text
calm
curious
team-oriented
```

### Expected Result

```text
The profile is saved in the database and linked to the authenticated user.
```

---

## Step 4: Select Avatar

### Screen

```text
Avatar Selection Screen
```

### Backend Endpoints

```text
GET /avatars
PUT /users/me/avatar
```

### Demo Explanation

The frontend fetches available avatars from the backend.

The user selects one avatar.

### Expected Result

```text
The selected avatar UUID is saved in user settings.
```

### Important Note

```text
The frontend must use avatar UUID values returned from GET /avatars.
Hardcoded values such as avatar_1 should not be used.
```

---

## Step 5: Select Mode

### Screen

```text
Mode Selection Screen
```

### Backend Endpoint

```text
PUT /users/me/mode
```

### Demo Explanation

The user selects one of the application modes:

```text
Dating / Social Mode
Networking / Business Mode
```

Backend values:

```text
social
networking
```

### Expected Result

```text
The selected mode is saved in the database.
```

---

## Step 6: Pair Device

### Screen

```text
Device Pairing Screen
```

### Backend Endpoints

```text
GET /devices/mock-nearby
POST /devices/pair
GET /devices/my-device
```

### Demo Explanation

For the MVP, the device pairing flow can be demonstrated with:

```text
Manual device code entry
Mock nearby device list
```

Example device:

```text
Device Code: MVP-DEVICE-001
Device Name: VEXA MVP Test Device 001
Model: LILYGO T-Display S3
Chipset: ESP32-S3R8
Connectivity: WiFi, BLE
```

### Expected Result

```text
The authenticated user is paired with a VEXA device.
The pairing record is stored in Supabase PostgreSQL.
```

### Device Note

```text
Real BLE discovery will be tested when the physical device is available.
The expected architecture is: VEXA Device <-> Flutter App <-> Backend.
```

---

## Step 7: Prepare Second User

### Screen

```text
Second User / Test User Setup
```

### Backend Endpoints

```text
POST /auth/register
POST /auth/login
PUT /users/me/profile
PUT /users/me/mode
```

### Demo Explanation

A second user is created or selected for match testing.

Example second user profile:

```text
Interests: technology, music, networking
Personality tags: curious, creative
Mode: networking
```

### Expected Result

```text
The second user is available as a match candidate.
```

---

## Step 8: View Match Candidates

### Screen

```text
Match Candidates Screen
```

### Backend Endpoint

```text
GET /matches/candidates
```

### Demo Explanation

The authenticated user views possible match candidates.

### Expected Result

```text
The backend returns other users with profile and mode information.
```

---

## Step 9: Check Match Compatibility

### Screen

```text
Match Check Screen
```

### Backend Endpoint

```text
POST /matches/check
```

### Demo Explanation

The application calculates compatibility between two users.

Current temporary matching logic:

```text
Each common interest: +25 points
Each common personality tag: +15 points
Same selected mode: +20 points
Maximum score: 100
Match threshold: 50
```

Example result:

```text
Common interests: technology, networking
Common personality tags: curious
Same mode: networking
Match score: 85
Status: detected
```

### Expected Result

```text
The backend calculates the match score and stores the match result in the database.
```

---

## Step 10: View Match History

### Screen

```text
Match History Screen
```

### Backend Endpoint

```text
GET /matches/history
```

### Demo Explanation

The user views previous match results.

### Expected Result

```text
The previously calculated match appears in match history.
```

---

## Suggested Demo Talk Track

During the demo, the system can be explained as follows:

```text
VEXA is designed as a wearable social and professional interaction system.

The user first creates an account and builds a profile by entering interests and personality tags.

The user then selects an avatar and chooses the preferred mode: Dating/Social or Networking/Business.

After that, the user pairs a VEXA device. In the MVP, device pairing is demonstrated through the backend pairing system. Real BLE discovery will be tested with the physical LILYGO T-Display S3 device.

The system then compares users based on shared interests, personality tags and selected mode. A match score is calculated and saved in the database.

Finally, the user can view match history.
```

---

## MVP Success Criteria

The MVP demo is considered successful if the following flow works:

```text
User registration works
Login works
JWT token is received
Profile creation works
Avatar selection works
Mode selection works
Device pairing works
Match candidates are listed
Match score is calculated
Match history is displayed
Data is stored in Supabase PostgreSQL
Production API works through Render
```

---

## Current Backend Readiness

Current backend status:

```text
Production API: Completed
Database connection: Completed
Authentication: Completed
User profile/settings: Completed
Avatar system: Completed
Device pairing: Completed for MVP
Matching system: Completed for MVP
Documentation: Completed
```

---

## Device-Related Demo Positioning

Since real BLE integration depends on physical device testing, the MVP can position the device flow as:

```text
The backend and app architecture already support user-device pairing.
The physical device will communicate with the Flutter app through BLE.
The Flutter app will send required pairing, interaction and match-related data to the backend.
```

Physical device discovery checklist:

```text
Check USB connection
Check board detection on Mac
Check screen test
Check BLE advertising
Check nRF Connect visibility
Collect service UUIDs
Collect characteristic UUIDs
Test BLE read/write behavior
```

---

## Backup Demo Plan

If physical BLE integration is not ready during the demo, use this backup plan:

```text
Show the physical VEXA device
Explain the intended BLE architecture
Use mock nearby device endpoint
Pair a device manually with a device code
Continue with match calculation and match history
```

This still demonstrates the core MVP logic:

```text
User profile
Mode selection
Device pairing
Matching
Database persistence
```

---

## Final Demo Checklist

Before the demo, verify:

```text
Production API is live
Supabase database is healthy
GET /health works
GET /db/health works
GET /avatars works
Register/login works
Frontend can store JWT token
Profile screen can save user data
Avatar selection uses real UUID
Mode selection sends social or networking
Device pairing screen works
Match check works
Match history works
```