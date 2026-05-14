# VEXA Demo Test Data

## Purpose

This document contains suggested test data for the VEXA MVP demo.

The purpose is to make the demo process easier and prevent confusion during presentation or testing.

---

## Production API

```text
https://vexa-backend-umg2.onrender.com/api
```

---

## Test User A

### Account Information

```text
Full Name: MVP User A
Email: mvp-user-a@example.com
Password: 123456
```

### Profile Data

```json
{
  "bio": "MVP test user A for VEXA demo.",
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
Full Name: MVP User B
Email: mvp-user-b@example.com
Password: 123456
```

### Profile Data

```json
{
  "bio": "MVP test user B for VEXA demo.",
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

When User A is matched with User B, the expected result is:

```text
Common interests: technology, networking
Common personality tags: curious
Same mode: true
Expected match score: 85
Expected status: detected
```

---

## Demo Device Data

For MVP demo, the device can be paired manually using this test data:

```json
{
  "deviceCode": "MVP-DEVICE-001",
  "deviceName": "VEXA MVP Test Device 001",
  "model": "LILYGO T-Display S3",
  "chipset": "ESP32-S3R8",
  "connectivity": ["WiFi", "BLE"]
}
```

---

## Recommended Demo Order

```text
1. Register User A
2. Login User A
3. Create profile for User A
4. Select avatar for User A
5. Select networking mode for User A
6. Pair MVP-DEVICE-001 with User A
7. Register User B
8. Login User B
9. Create profile for User B
10. Select networking mode for User B
11. Use User A to check match with User B
12. Show match score
13. Show match history
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

## Notes

```text
Passwords are simple because these users are only for MVP demo testing.
Real user accounts should not use weak passwords.
If an email already exists during testing, either login with the same account or create a new test email.
```

Example alternative emails:

```text
mvp-user-a2@example.com
mvp-user-b2@example.com
demo-user-a@example.com
demo-user-b@example.com
```

---

## Important Reminder

Most IDs are UUID values. The frontend should use values returned from the API.

Do not hardcode:

```text
user_1
avatar_1
device_1
match_1
```