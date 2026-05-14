const express = require("express");

const authMiddleware = require("../middlewares/auth.middleware");
const db = require("../config/db");

const router = express.Router();

const getCommonItems = (firstList = [], secondList = []) => {
  return firstList.filter((item) => secondList.includes(item));
};

router.get("/candidates", authMiddleware, async (req, res) => {
  try {
    const result = await db.query(
      `SELECT
        u.id,
        u.email,
        u.full_name AS "fullName",
        p.bio,
        p.interests,
        p.personality_tags AS "personalityTags",
        us.selected_avatar_id AS "selectedAvatarId",
        us.selected_mode AS "selectedMode",
        us.is_available AS "isAvailable"
       FROM users u
       LEFT JOIN profiles p ON p.user_id = u.id
       LEFT JOIN user_settings us ON us.user_id = u.id
       WHERE u.id <> $1
       ORDER BY u.created_at DESC`,
      [req.user.userId]
    );

    const candidates = result.rows.map((row) => ({
      id: row.id,
      email: row.email,
      fullName: row.fullName,
      profile: row.bio
        ? {
            bio: row.bio,
            interests: row.interests || [],
            personalityTags: row.personalityTags || []
          }
        : null,
      settings:
        row.selectedAvatarId || row.selectedMode
          ? {
              selectedAvatarId: row.selectedAvatarId,
              selectedMode: row.selectedMode,
              isAvailable: row.isAvailable
            }
          : null
    }));

    res.json({
      success: true,
      data: candidates
    });
  } catch (error) {
    console.error("Failed to fetch match candidates:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch match candidates"
    });
  }
});

router.post("/check", authMiddleware, async (req, res) => {
  try {
    const { targetUserId, targetEmail } = req.body;

    if (!targetUserId && !targetEmail) {
      return res.status(400).json({
        success: false,
        message: "targetUserId or targetEmail is required"
      });
    }

    const currentUserResult = await db.query(
      `SELECT
        u.id,
        u.email,
        u.full_name AS "fullName",
        p.interests,
        p.personality_tags AS "personalityTags",
        us.selected_mode AS "selectedMode"
       FROM users u
       LEFT JOIN profiles p ON p.user_id = u.id
       LEFT JOIN user_settings us ON us.user_id = u.id
       WHERE u.id = $1`,
      [req.user.userId]
    );

    const currentUser = currentUserResult.rows[0];

    if (!currentUser) {
      return res.status(404).json({
        success: false,
        message: "Current user not found"
      });
    }

    const targetUserResult = await db.query(
      `SELECT
        u.id,
        u.email,
        u.full_name AS "fullName",
        p.interests,
        p.personality_tags AS "personalityTags",
        us.selected_mode AS "selectedMode"
       FROM users u
       LEFT JOIN profiles p ON p.user_id = u.id
       LEFT JOIN user_settings us ON us.user_id = u.id
       WHERE u.id::text = $1 OR u.email = $2
       LIMIT 1`,
      [targetUserId || "", targetEmail || ""]
    );

    const targetUser = targetUserResult.rows[0];

    if (!targetUser) {
      return res.status(404).json({
        success: false,
        message: "Target user not found"
      });
    }

    if (currentUser.id === targetUser.id) {
      return res.status(400).json({
        success: false,
        message: "User cannot match with themselves"
      });
    }

    const commonInterests = getCommonItems(
      currentUser.interests || [],
      targetUser.interests || []
    );

    const commonPersonalityTags = getCommonItems(
      currentUser.personalityTags || [],
      targetUser.personalityTags || []
    );

    const sameMode =
      currentUser.selectedMode &&
      targetUser.selectedMode &&
      currentUser.selectedMode === targetUser.selectedMode;

    const score = Math.min(
      100,
      commonInterests.length * 25 +
        commonPersonalityTags.length * 15 +
        (sameMode ? 20 : 0)
    );

    const isMatch = score >= 50;

    const existingMatchResult = await db.query(
      `SELECT *
       FROM matches
       WHERE 
        (user_id_1 = $1 AND user_id_2 = $2)
        OR
        (user_id_1 = $2 AND user_id_2 = $1)
       LIMIT 1`,
      [currentUser.id, targetUser.id]
    );

    let matchResult;

    if (existingMatchResult.rows.length > 0) {
      matchResult = await db.query(
        `UPDATE matches
         SET
          match_score = $1,
          common_interests = $2,
          common_personality_tags = $3,
          same_mode = $4,
          mode = $5,
          status = $6,
          updated_at = CURRENT_TIMESTAMP
         WHERE id = $7
         RETURNING
          id,
          user_id_1 AS "userId1",
          user_id_2 AS "userId2",
          match_score AS "matchScore",
          common_interests AS "commonInterests",
          common_personality_tags AS "commonPersonalityTags",
          same_mode AS "sameMode",
          mode,
          status,
          created_at AS "createdAt",
          updated_at AS "updatedAt"`,
        [
          score,
          commonInterests,
          commonPersonalityTags,
          Boolean(sameMode),
          currentUser.selectedMode || null,
          isMatch ? "detected" : "not_matched",
          existingMatchResult.rows[0].id
        ]
      );

      return res.json({
        success: true,
        data: matchResult.rows[0]
      });
    }

    matchResult = await db.query(
      `INSERT INTO matches (
        user_id_1,
        user_id_2,
        match_score,
        common_interests,
        common_personality_tags,
        same_mode,
        mode,
        status
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING
        id,
        user_id_1 AS "userId1",
        user_id_2 AS "userId2",
        match_score AS "matchScore",
        common_interests AS "commonInterests",
        common_personality_tags AS "commonPersonalityTags",
        same_mode AS "sameMode",
        mode,
        status,
        created_at AS "createdAt",
        updated_at AS "updatedAt"`,
      [
        currentUser.id,
        targetUser.id,
        score,
        commonInterests,
        commonPersonalityTags,
        Boolean(sameMode),
        currentUser.selectedMode || null,
        isMatch ? "detected" : "not_matched"
      ]
    );

    await db.query(
      `INSERT INTO match_history (match_id, event_type, event_description)
       VALUES ($1, $2, $3)`,
      [
        matchResult.rows[0].id,
        "match_checked",
        `Match score calculated as ${score}`
      ]
    );

    res.status(201).json({
      success: true,
      data: matchResult.rows[0]
    });
  } catch (error) {
    console.error("Match check failed:", error);

    res.status(500).json({
      success: false,
      message: "Match check failed"
    });
  }
});

router.get("/history", authMiddleware, async (req, res) => {
  try {
    const result = await db.query(
      `SELECT
        m.id,
        m.user_id_1 AS "userId1",
        m.user_id_2 AS "userId2",
        m.match_score AS "matchScore",
        m.common_interests AS "commonInterests",
        m.common_personality_tags AS "commonPersonalityTags",
        m.same_mode AS "sameMode",
        m.mode,
        m.status,
        m.created_at AS "createdAt",
        m.updated_at AS "updatedAt",
        other_user.id AS "otherUserId",
        other_user.email AS "otherUserEmail",
        other_user.full_name AS "otherUserFullName"
       FROM matches m
       JOIN users other_user
        ON other_user.id = CASE
          WHEN m.user_id_1 = $1 THEN m.user_id_2
          ELSE m.user_id_1
        END
       WHERE m.user_id_1 = $1 OR m.user_id_2 = $1
       ORDER BY m.updated_at DESC`,
      [req.user.userId]
    );

    const history = result.rows.map((row) => ({
      id: row.id,
      userId1: row.userId1,
      userId2: row.userId2,
      matchScore: row.matchScore,
      commonInterests: row.commonInterests || [],
      commonPersonalityTags: row.commonPersonalityTags || [],
      sameMode: row.sameMode,
      mode: row.mode,
      status: row.status,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      otherUser: {
        id: row.otherUserId,
        email: row.otherUserEmail,
        fullName: row.otherUserFullName
      }
    }));

    res.json({
      success: true,
      data: history
    });
  } catch (error) {
    console.error("Failed to fetch match history:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch match history"
    });
  }
});

module.exports = router;