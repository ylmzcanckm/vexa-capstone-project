const express = require("express");
const db = require("../config/db");

const router = express.Router();

router.get("/health", async (req, res) => {
  try {
    const result = await db.query("SELECT NOW() AS current_time");

    res.json({
      success: true,
      message: "Database connection is working",
      data: result.rows[0]
    });
  } catch (error) {
    console.error("Database health check failed:", error);

    res.status(500).json({
      success: false,
      message: "Database connection failed"
    });
  }
});

router.get("/avatars", async (req, res) => {
  try {
    const result = await db.query(
      `SELECT 
        id,
        name,
        image_url AS "imageUrl",
        created_at AS "createdAt",
        updated_at AS "updatedAt"
      FROM avatars
      ORDER BY name ASC`
    );

    res.json({
      success: true,
      data: result.rows
    });
  } catch (error) {
    console.error("Avatar query failed:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch avatars from database"
    });
  }
});

module.exports = router;