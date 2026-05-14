const express = require("express");

const authMiddleware = require("../middlewares/auth.middleware");
const db = require("../config/db");

const router = express.Router();

router.get("/me", authMiddleware, async (req, res) => {
  try {
    const userResult = await db.query(
      `SELECT 
        id,
        email,
        full_name AS "fullName",
        created_at AS "createdAt",
        updated_at AS "updatedAt"
       FROM users
       WHERE id = $1`,
      [req.user.userId]
    );

    const user = userResult.rows[0];

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found"
      });
    }

    const profileResult = await db.query(
      `SELECT
        user_id AS "userId",
        bio,
        interests,
        personality_tags AS "personalityTags",
        created_at AS "createdAt",
        updated_at AS "updatedAt"
       FROM profiles
       WHERE user_id = $1`,
      [req.user.userId]
    );

    const settingsResult = await db.query(
      `SELECT
        user_id AS "userId",
        selected_avatar_id AS "selectedAvatarId",
        selected_mode AS "selectedMode",
        is_available AS "isAvailable",
        created_at AS "createdAt",
        updated_at AS "updatedAt"
       FROM user_settings
       WHERE user_id = $1`,
      [req.user.userId]
    );

    res.json({
      success: true,
      data: {
        ...user,
        profile: profileResult.rows[0] || null,
        settings: settingsResult.rows[0] || null
      }
    });
  } catch (error) {
    console.error("Failed to fetch user:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch user"
    });
  }
});

router.put("/me/profile", authMiddleware, async (req, res) => {
  try {
    const { bio, interests, personalityTags } = req.body;

    const result = await db.query(
      `INSERT INTO profiles (user_id, bio, interests, personality_tags)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (user_id)
       DO UPDATE SET
        bio = EXCLUDED.bio,
        interests = EXCLUDED.interests,
        personality_tags = EXCLUDED.personality_tags,
        updated_at = CURRENT_TIMESTAMP
       RETURNING
        user_id AS "userId",
        bio,
        interests,
        personality_tags AS "personalityTags",
        created_at AS "createdAt",
        updated_at AS "updatedAt"`,
      [
        req.user.userId,
        bio || "",
        interests || [],
        personalityTags || []
      ]
    );

    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error("Failed to update profile:", error);

    res.status(500).json({
      success: false,
      message: "Failed to update profile"
    });
  }
});

router.put("/me/avatar", authMiddleware, async (req, res) => {
  try {
    const { avatarId } = req.body;

    if (!avatarId) {
      return res.status(400).json({
        success: false,
        message: "avatarId is required"
      });
    }

    const avatarResult = await db.query(
      "SELECT id FROM avatars WHERE id::text = $1",
      [avatarId]
    );

    const avatar = avatarResult.rows[0];

    if (!avatar) {
      return res.status(404).json({
        success: false,
        message: "Avatar not found"
      });
    }

    const result = await db.query(
      `INSERT INTO user_settings (user_id, selected_avatar_id)
       VALUES ($1, $2)
       ON CONFLICT (user_id)
       DO UPDATE SET
        selected_avatar_id = EXCLUDED.selected_avatar_id,
        updated_at = CURRENT_TIMESTAMP
       RETURNING
        user_id AS "userId",
        selected_avatar_id AS "selectedAvatarId",
        selected_mode AS "selectedMode",
        is_available AS "isAvailable",
        created_at AS "createdAt",
        updated_at AS "updatedAt"`,
      [req.user.userId, avatar.id]
    );

    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error("Failed to update avatar:", error);

    res.status(500).json({
      success: false,
      message: "Failed to update avatar"
    });
  }
});

router.put("/me/mode", authMiddleware, async (req, res) => {
  try {
    const { mode } = req.body;

    const allowedModes = ["social", "networking"];

    if (!mode || !allowedModes.includes(mode)) {
      return res.status(400).json({
        success: false,
        message: "mode must be either social or networking"
      });
    }

    const result = await db.query(
      `INSERT INTO user_settings (user_id, selected_mode)
       VALUES ($1, $2)
       ON CONFLICT (user_id)
       DO UPDATE SET
        selected_mode = EXCLUDED.selected_mode,
        updated_at = CURRENT_TIMESTAMP
       RETURNING
        user_id AS "userId",
        selected_avatar_id AS "selectedAvatarId",
        selected_mode AS "selectedMode",
        is_available AS "isAvailable",
        created_at AS "createdAt",
        updated_at AS "updatedAt"`,
      [req.user.userId, mode]
    );

    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error("Failed to update mode:", error);

    res.status(500).json({
      success: false,
      message: "Failed to update mode"
    });
  }
});

module.exports = router;