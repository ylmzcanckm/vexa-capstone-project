# VEXA Demo Test Data

## Purpose

This document contains safe and reusable test data examples for the VEXA MVP demo.

The purpose is to simplify presentations and testing without exposing active account credentials or private configuration values.

---

## Production API

```text
https://vexa-backend-umg2.onrender.com/api
```

The API address is public project information and does not contain authentication credentials.

---

## Test User A

### Account Information

```text
Full Name: Demo User A
Email: demo-user-a@example.com
Password: <SET_LOCALLY_DO_NOT_COMMIT>
```

### Profile Data

```json
{
  "bio": "Demo user A for the VEXA MVP.",
  "interests": ["technology", "gaming", "networking"],
  "personalityTags": ["calm", "curious", "team-oriented"]
}
```

### Mode

```text
networking
```

### Avatar

Use one of the UUID values returned from:

```text
GET /avatars
```

Suggested avatar:

```text
Blue Avatar
```

---

## Test User B

### Account Information

```text
Full Name: Demo User B
Email: demo-user-b@example.com
Password: <SET_LOCALLY_DO_NOT_COMMIT>
```

### Profile Data

```json
{
  "bio": "Demo user B for the VEXA MVP.",
  "interests": ["technology", "music", "networking"],
  "personalityTags": ["curious", "creative"]
}
```

### Mode

```text
networking
```

---

## Expected Match Result

The final VEXA matching experience uses a five-question live quiz.

```text
Total questions: 5
Required agreement: 4 out of 5
Match threshold: 80%
Expected result: Match successful
```

After a successful match, the mobile application informs both users and the VEXA device helps guide them toward each other.

---

## Demo Device Data

For the MVP demo, a device can be paired manually using example data such as:

```json
{
  "deviceCode": "DEMO-DEVICE-001",
  "deviceName": "VEXA Demo Device 001",
  "model": "LILYGO T-Display S3",
  "chipset": "ESP32-S3R8",
  "connectivity": ["WiFi", "BLE"]
}
```

---

## Recommended Demo Order

```text
1. Register Demo User A
2. Login as Demo User A
3. Create the profile for Demo User A
4. Select an avatar
5. Select the preferred VEXA mode
6. Pair DEMO-DEVICE-001
7. Register Demo User B
8. Login as Demo User B
9. Create the profile for Demo User B
10. Select the preferred VEXA mode
11. Start the live five-question quiz
12. Complete at least four questions with matching answers
13. Display the successful match result
14. Show the match in the user history
```

---

## Useful Endpoint Order

```text
POST /auth/register
POST /auth/login
PUT /users/me/profile
GET /avatars
PUT /users/me/avatar
PUT /users/me/mode
POST /devices/pair
GET /devices/my-device
GET /matches/candidates
POST /matches/check
GET /matches/history
```

---

## Security Notes

```text
Create demo accounts only when they are needed.
Use unique and strong passwords for all active accounts.
Store active passwords outside the repository.
Never commit real credentials, tokens, private keys or database connection strings.
Delete temporary demo accounts after testing is complete.
```

Example placeholder emails:

```text
demo-user-a@example.com
demo-user-b@example.com
test-user-a@example.com
test-user-b@example.com
```

---

## Important Reminder

Most IDs are UUID values returned by the backend.

The frontend should always use the real values returned from API responses.

Do not hardcode placeholder IDs such as:

```text
user_1
avatar_1
device_1
match_1
```
