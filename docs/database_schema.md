# VEXA Database Schema

## Overview

This document defines the planned database structure for the VEXA backend.

The current backend uses an in-memory temporary store. This means that users, profiles, settings, devices and pairings are deleted when the server restarts.

In the next development phase, this temporary structure will be replaced with a real database.

Recommended database option:

```text
PostgreSQL
```

Possible implementation options:

```text
Supabase PostgreSQL
Local PostgreSQL
Managed PostgreSQL service
```

---

## Main Entities

The backend will need the following main tables:

```text
users
profiles
user_settings
avatars
devices
device_pairings
matches
match_history
```

---

## 1. users

Stores the main account information of each user.

### Fields

```text
id
email
password_hash
full_name
created_at
updated_at
```

### Example Structure

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Notes

```text
email must be unique.
password_hash stores the hashed password, not the raw password.
```

---

## 2. profiles

Stores additional user profile information.

### Fields

```text
id
user_id
bio
interests
personality_tags
created_at
updated_at
```

### Example Structure

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  bio TEXT,
  interests TEXT[],
  personality_tags TEXT[],
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Relationship

```text
One user has one profile.
profiles.user_id references users.id.
```

---

## 3. user_settings

Stores user-specific app settings such as selected avatar, selected mode and availability status.

### Fields

```text
id
user_id
selected_avatar_id
selected_mode
is_available
created_at
updated_at
```

### Example Structure

```sql
CREATE TABLE user_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  selected_avatar_id UUID REFERENCES avatars(id),
  selected_mode VARCHAR(50),
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Allowed Modes

```text
social
networking
```

### Relationship

```text
One user has one settings record.
user_settings.user_id references users.id.
user_settings.selected_avatar_id references avatars.id.
```

---

## 4. avatars

Stores available avatar options.

### Fields

```text
id
name
image_url
created_at
updated_at
```

### Example Structure

```sql
CREATE TABLE avatars (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  image_url TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Notes

```text
The current backend uses mock avatar URLs.
Real avatar assets will be added later.
```

---

## 5. devices

Stores physical VEXA device information.

### Fields

```text
id
device_code
device_name
model
chipset
connectivity
status
created_at
updated_at
```

### Example Structure

```sql
CREATE TABLE devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_code VARCHAR(255) UNIQUE NOT NULL,
  device_name VARCHAR(255),
  model VARCHAR(255),
  chipset VARCHAR(255),
  connectivity TEXT[],
  status VARCHAR(50) DEFAULT 'available',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Example Device Data

```text
device_code: XY251108-H569-001
device_name: VEXA T-Display S3 001
model: LILYGO T-Display S3
chipset: ESP32-S3R8
connectivity: WiFi, BLE
status: paired
```

---

## 6. device_pairings

Stores which user is paired with which device.

### Fields

```text
id
user_id
device_id
paired_at
unpaired_at
status
```

### Example Structure

```sql
CREATE TABLE device_pairings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  paired_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  unpaired_at TIMESTAMP,
  status VARCHAR(50) DEFAULT 'active'
);
```

### Relationship

```text
One user can have one active paired device.
One device can have one active paired user.
```

### Notes

```text
When the user unpairs the device, status can be changed to inactive.
The current in-memory backend deletes the pairing directly.
In the real database version, keeping historical pairing records may be useful.
```

---

## 7. matches

Stores match records between two users.

### Fields

```text
id
user_id_1
user_id_2
match_score
mode
status
created_at
updated_at
```

### Example Structure

```sql
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id_1 UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_id_2 UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  match_score INTEGER,
  mode VARCHAR(50),
  status VARCHAR(50) DEFAULT 'detected',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Possible Status Values

```text
detected
accepted
ignored
expired
```

### Notes

```text
This table will be used later when the matching logic is implemented.
```

---

## 8. match_history

Stores detailed interaction history related to matches.

### Fields

```text
id
match_id
event_type
event_description
created_at
```

### Example Structure

```sql
CREATE TABLE match_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  event_type VARCHAR(100),
  event_description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Example Event Types

```text
match_detected
notification_sent
device_vibrated
user_viewed_match
match_accepted
match_ignored
```

---

## Relationship Summary

```text
users 1 - 1 profiles
users 1 - 1 user_settings
avatars 1 - many user_settings
users 1 - many device_pairings
devices 1 - many device_pairings
users many - many users through matches
matches 1 - many match_history
```

---

## Current Backend Mapping

The current in-memory backend has the following temporary structures:

```text
users
profiles
userSettings
devices
devicePairings
```

These will later map to real database tables:

```text
users -> users table
profiles -> profiles table
userSettings -> user_settings table
devices -> devices table
devicePairings -> device_pairings table
```

---

## Next Database Tasks

```text
1. Choose the final database technology.
2. Create real database connection configuration.
3. Replace memoryStore.js with database queries.
4. Add database migrations.
5. Seed default avatar records.
6. Update register/login endpoints to use the users table.
7. Update profile/settings/device endpoints to use database tables.
```

---

## Important Note

This schema is a planning document. It may be updated as the project requirements become clearer, especially after real BLE testing and matching logic implementation.