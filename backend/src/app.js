require("dotenv").config();

const express = require("express");
const cors = require("cors");

const authRoutes = require("./routes/auth.routes");
const avatarRoutes = require("./routes/avatar.routes");
const deviceRoutes = require("./routes/device.routes");
const userRoutes = require("./routes/user.routes");
const matchRoutes = require("./routes/match.routes");
const dbRoutes = require("./routes/db.routes");
const { runMigrations } = require("./config/migrate");

const app = express();

app.use(cors());
app.use(express.json());

app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    message: "VEXA backend is running"
  });
});

app.use("/api/auth", authRoutes);
app.use("/api/avatars", avatarRoutes);
app.use("/api/devices", deviceRoutes);
app.use("/api/users", userRoutes);
app.use("/api/matches", matchRoutes);
app.use("/api/db", dbRoutes);

const PORT = process.env.PORT || 3000;

runMigrations()
  .catch((error) => {
    console.error("Startup migration error:", error.message);
  })
  .finally(() => {
    app.listen(PORT, "0.0.0.0", () => {
      console.log(`Backend running on port ${PORT}`);
    });
  });