const express = require("express");
const db = require("../config/db");

const router = express.Router();

router.get("/", async (req, res) => {
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
    console.error("Failed to fetch avatars:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch avatars"
    });
  }
});

module.exports = router;