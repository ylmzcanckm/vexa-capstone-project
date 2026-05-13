# VEXA Project

VEXA is a wearable device and mobile application project designed to support proximity-based social and professional interaction.

The project currently includes:

```text
backend/
frontend/
docs/
```

---

## Project Structure

```text
vexa-project/
│
├── backend/      # Node.js / Express backend
├── frontend/     # Flutter mobile application
├── docs/         # API contract, database schema and device notes
└── README.md
```

---

## Backend Tech Stack

```text
Node.js
Express.js
JWT
bcryptjs
dotenv
CORS
```

---

## Current Backend Features

```text
Auth register/login
JWT token generation
Protected user endpoints
User profile update
Avatar selection
Mode selection
Mock device list
Device pairing
Match score calculation
Match history
```

---

## Backend Setup

Go to the backend folder:

```bash
cd backend
```

Install dependencies:

```bash
npm install
```

Create a `.env` file inside the `backend` folder:

```bash
JWT_SECRET=your_jwt_secret_here
```

Start the backend server:

```bash
npm run dev
```

The backend will run on:

```text
http://localhost:3000
```

Base API URL:

```text
http://localhost:3000/api
```

---

## Health Check

To check if the backend is running:

```text
GET http://localhost:3000/api/health
```

Expected response:

```json
{
  "success": true,
  "message": "VEXA backend is running"
}
```

---

## Important Documents

```text
docs/api_contract.md       # API endpoints and request/response formats
docs/database_schema.md    # Planned database schema
docs/device_notes.md       # Device information and BLE investigation notes
```

---

## Branch Workflow

The project uses a branch-based workflow.

Main branches:

```text
main   # Stable version
dev    # Active development branch
```

Feature branches:

```text
backend/auth
backend/user-profile
backend/device-pairing
backend/matching
docs/readme-setup
```

General workflow:

```bash
git checkout dev
git pull origin dev
git checkout -b branch-name
```

After development:

```bash
git add .
git commit -m "Commit message"
git push -u origin branch-name
```

Then open a Pull Request on GitHub:

```text
base: dev
compare: branch-name
```

---

## Current Development Note

The backend currently uses an in-memory temporary store. This means data is deleted when the server restarts.

A real database will be added in a later phase.