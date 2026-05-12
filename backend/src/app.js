const express = require("express");
const cors = require("cors");

const avatarRoutes = require("./routes/avatar.routes");
const deviceRoutes = require("./routes/device.routes");

const app = express();

app.use(cors());
app.use(express.json());

app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    message: "VEXA backend is running"
  });
});

app.use("/api/avatars", avatarRoutes);
app.use("/api/devices", deviceRoutes);

const PORT = 3000;

app.listen(PORT, () => {
  console.log(`Backend running on http://localhost:${PORT}`);
});