const express = require("express");

const authMiddleware = require("../middlewares/auth.middleware");
const db = require("../config/db");
const {
  decodeBioProfile,
  passesDiscoveryFilters,
  compareQuizAnswers
} = require("../services/vexa_profile.service");
const {
  selectQuestionsForMatch,
  QUESTION_COUNT
} = require("../services/quiz_catalog.service");

const router = express.Router();

const COOLDOWN_HOURS = 2;

const getCommonItems = (firstList = [], secondList = []) => {
  return firstList.filter((item) => secondList.includes(item));
};

// Aktif eşleşme molası (yoksa null). Tablo henüz yoksa sessizce geçer
// (migration çalıştırılmadan deploy edilirse uygulama kırılmasın).
const getActiveCooldown = async (userId) => {
  try {
    const result = await db.query(
      `SELECT cooldown_until AS "cooldownUntil"
       FROM match_cooldowns
       WHERE user_id = $1 AND cooldown_until > NOW()`,
      [userId]
    );
    return result.rows[0] ? result.rows[0].cooldownUntil : null;
  } catch (_) {
    return null;
  }
};

const setCooldownForUsers = async (userIds, cooldownUntil) => {
  try {
    for (const userId of userIds) {
      await db.query(
        `INSERT INTO match_cooldowns (user_id, cooldown_until)
         VALUES ($1, $2)
         ON CONFLICT (user_id)
         DO UPDATE SET
          cooldown_until = EXCLUDED.cooldown_until,
          updated_at = CURRENT_TIMESTAMP`,
        [userId, cooldownUntil]
      );
    }
  } catch (error) {
    console.error("Failed to set match cooldown:", error);
  }
};

const clearQuizSession = async (matchId) => {
  await db.query(`DELETE FROM match_quiz_answers WHERE match_id = $1`, [matchId]);
};

// Karşı tarafın cevapları bu eşleşme oturumuna ait mi?
const isAnswerFreshForMatch = (answerRow, matchUpdatedAt) => {
  if (!answerRow?.updatedAt || !matchUpdatedAt) return false;
  return new Date(answerRow.updatedAt) >= new Date(matchUpdatedAt);
};

const expectedQuestionKeysForMatch = (match) =>
  selectQuestionsForMatch(match.id, match.commonInterests || []).map((q) => q.key);

const loadMatchForUser = async (matchId, userId) => {
  const result = await db.query(
    `SELECT
      id,
      user_id_1 AS "userId1",
      user_id_2 AS "userId2",
      status,
      common_interests AS "commonInterests",
      quiz_percent AS "quizPercent",
      quiz_completed_at AS "quizCompletedAt",
      updated_at AS "updatedAt"
     FROM matches
     WHERE id::text = $1`,
    [matchId]
  );

  const match = result.rows[0];
  if (!match) return null;
  if (match.userId1 !== userId && match.userId2 !== userId) return null;
  return match;
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
        p.bio,
        p.interests,
        p.personality_tags AS "personalityTags",
        p.discovery_filters AS "discoveryFilters",
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
        p.bio,
        p.interests,
        p.personality_tags AS "personalityTags",
        p.discovery_filters AS "discoveryFilters",
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

    // 2 saatlik eşleşme molası: taraflardan biri moladaysa eşleşme yapılmaz.
    const myCooldown = await getActiveCooldown(currentUser.id);
    const targetCooldown = await getActiveCooldown(targetUser.id);
    const activeCooldown = myCooldown || targetCooldown;

    if (activeCooldown) {
      return res.status(409).json({
        success: false,
        message:
          "Eşleşme molası aktif — quiz sonrası 2 saat yeni eşleşme yapılamaz.",
        cooldownUntil: activeCooldown
      });
    }

    // Tanışma filtreleri: iki tarafın filtresi de karşı tarafa tam uymalı.
    const filtersOk =
      passesDiscoveryFilters(
        currentUser.discoveryFilters,
        decodeBioProfile(targetUser.bio)
      ) &&
      passesDiscoveryFilters(
        targetUser.discoveryFilters,
        decodeBioProfile(currentUser.bio)
      );

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

    // detected: skor yeterli + filtreler uyumlu
    // filtered: skor yeterli ama filtreler uyuşmuyor (quiz daveti çıkmaz)
    const matchStatus = isMatch
      ? filtersOk
        ? "detected"
        : "filtered"
      : "not_matched";

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
      const existingMatchId = existingMatchResult.rows[0].id;

      // Yeni quiz oturumu: eski cevapları sil (hızlı bitiren tarafın yanlış
      // sonuç görmesini önler).
      if (matchStatus === "detected") {
        await clearQuizSession(existingMatchId);
      }

      matchResult = await db.query(
        `UPDATE matches
         SET
          match_score = $1,
          common_interests = $2,
          common_personality_tags = $3,
          same_mode = $4,
          mode = $5,
          status = $6,
          quiz_percent = CASE WHEN $6 = 'detected' THEN NULL ELSE quiz_percent END,
          quiz_completed_at = CASE WHEN $6 = 'detected' THEN NULL ELSE quiz_completed_at END,
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
          matchStatus,
          existingMatchId
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
        matchStatus
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

// Quiz oturumu başlat: eski cevapları sil, kanonik 5 soruyu döndür.
router.post("/:matchId/quiz/begin", authMiddleware, async (req, res) => {
  try {
    const match = await loadMatchForUser(req.params.matchId, req.user.userId);

    if (!match) {
      return res.status(404).json({
        success: false,
        message: "Match not found"
      });
    }

    await clearQuizSession(match.id);
    await db.query(
      `UPDATE matches
       SET
        quiz_percent = NULL,
        quiz_completed_at = NULL,
        status = CASE WHEN status = 'quiz_failed' THEN 'detected' ELSE status END
       WHERE id = $1`,
      [match.id]
    );

    const questions = selectQuestionsForMatch(
      match.id,
      match.commonInterests || []
    );

    res.json({
      success: true,
      data: {
        matchId: match.id,
        commonInterests: match.commonInterests || [],
        questions
      }
    });
  } catch (error) {
    console.error("Failed to begin quiz session:", error);

    res.status(500).json({
      success: false,
      message: "Failed to begin quiz session"
    });
  }
});

// Canlı quiz: kullanıcının 5 cevabını kaydeder. İki taraf da gönderince
// sonucu hesaplar, match'e yazar ve iki kullanıcıya 2 saatlik mola başlatır.
router.post("/:matchId/quiz/answers", authMiddleware, async (req, res) => {
  try {
    const { answers } = req.body;

    if (
      !answers ||
      typeof answers !== "object" ||
      Array.isArray(answers) ||
      Object.keys(answers).length === 0
    ) {
      return res.status(400).json({
        success: false,
        message: "answers must be a non-empty object"
      });
    }

    const match = await loadMatchForUser(req.params.matchId, req.user.userId);

    if (!match) {
      return res.status(404).json({
        success: false,
        message: "Match not found"
      });
    }

    const expectedKeys = expectedQuestionKeysForMatch(match);
    const submittedKeys = Object.keys(answers).sort();

    if (
      submittedKeys.length !== QUESTION_COUNT ||
      submittedKeys.join("|") !== expectedKeys.sort().join("|")
    ) {
      return res.status(400).json({
        success: false,
        message:
          "answers must contain exactly the 5 canonical question keys for this match",
        expectedKeys
      });
    }

    await db.query(
      `INSERT INTO match_quiz_answers (match_id, user_id, answers)
       VALUES ($1, $2, $3)
       ON CONFLICT (match_id, user_id)
       DO UPDATE SET
        answers = EXCLUDED.answers,
        updated_at = CURRENT_TIMESTAMP`,
      [match.id, req.user.userId, JSON.stringify(answers)]
    );

    const rowsResult = await db.query(
      `SELECT user_id AS "userId", answers, updated_at AS "updatedAt"
       FROM match_quiz_answers
       WHERE match_id = $1`,
      [match.id]
    );

    const mine = rowsResult.rows.find((r) => r.userId === req.user.userId);
    const partner = rowsResult.rows.find((r) => r.userId !== req.user.userId);

    const partnerReady =
      partner && isAnswerFreshForMatch(partner, match.updatedAt);
    const mineReady = mine && isAnswerFreshForMatch(mine, match.updatedAt);

    if (!partnerReady || !mineReady) {
      return res.json({
        success: true,
        data: { bothSubmitted: false }
      });
    }

    const comparison = compareQuizAnswers(
      mine.answers,
      partner.answers,
      expectedKeys
    );
    const cooldownUntil = new Date(
      Date.now() + COOLDOWN_HOURS * 60 * 60 * 1000
    ).toISOString();

    await db.query(
      `UPDATE matches
       SET
        quiz_percent = $1,
        quiz_completed_at = CURRENT_TIMESTAMP,
        status = $2,
        updated_at = CURRENT_TIMESTAMP
       WHERE id = $3`,
      [comparison.percent, comparison.passed ? "completed" : "quiz_failed", match.id]
    );

    await setCooldownForUsers([match.userId1, match.userId2], cooldownUntil);

    res.json({
      success: true,
      data: {
        bothSubmitted: true,
        matching: comparison.matching,
        total: comparison.total,
        percent: comparison.percent,
        passed: comparison.passed,
        keyMismatch: comparison.keyMismatch === true,
        partnerAnswers: partner.answers,
        cooldownUntil
      }
    });
  } catch (error) {
    console.error("Failed to submit quiz answers:", error);

    res.status(500).json({
      success: false,
      message: "Failed to submit quiz answers"
    });
  }
});

// Canlı quiz durumu: karşı taraf bitirdi mi, sonuç ne?
// Karşı tarafın cevapları yalnızca iki taraf da gönderince döner.
router.get("/:matchId/quiz", authMiddleware, async (req, res) => {
  try {
    const match = await loadMatchForUser(req.params.matchId, req.user.userId);

    if (!match) {
      return res.status(404).json({
        success: false,
        message: "Match not found"
      });
    }

    const rowsResult = await db.query(
      `SELECT user_id AS "userId", answers, updated_at AS "updatedAt"
       FROM match_quiz_answers
       WHERE match_id = $1`,
      [match.id]
    );

    const mine = rowsResult.rows.find((r) => r.userId === req.user.userId);
    const partner = rowsResult.rows.find((r) => r.userId !== req.user.userId);
    const bothSubmitted = Boolean(
      mine &&
        partner &&
        isAnswerFreshForMatch(mine, match.updatedAt) &&
        isAnswerFreshForMatch(partner, match.updatedAt)
    );

    let comparison = null;
    if (bothSubmitted) {
      const expectedKeys = expectedQuestionKeysForMatch(match);
      comparison = compareQuizAnswers(
        mine.answers,
        partner.answers,
        expectedKeys
      );
    }

    const cooldownUntil = await getActiveCooldown(req.user.userId);

    res.json({
      success: true,
      data: {
        bothSubmitted,
        mySubmitted: Boolean(mine),
        partnerSubmitted: Boolean(partner),
        ...(bothSubmitted
          ? {
              matching: comparison.matching,
              total: comparison.total,
              percent: comparison.percent,
              passed: comparison.passed,
              partnerAnswers: partner.answers
            }
          : {}),
        cooldownUntil
      }
    });
  } catch (error) {
    console.error("Failed to fetch quiz session:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch quiz session"
    });
  }
});

router.get("/history", authMiddleware, async (req, res) => {
  try {
    const modeFilter = req.query.mode;
    const params = [req.user.userId];
    let modeClause = "";
    let visibilityClause = "";

    if (modeFilter === "social" || modeFilter === "networking") {
      params.push(modeFilter);
      modeClause = ` AND m.mode = $${params.length}`;

      if (modeFilter === "social") {
        // Sosyal geçmiş: yalnızca quiz geçilen eşleşmeler.
        visibilityClause =
          " AND m.quiz_percent IS NOT NULL AND m.quiz_percent >= 80";
      } else {
        // Network geçmiş: quiz yok — eşleşme tespit edilince kart düşer.
        visibilityClause = " AND m.status IN ('detected', 'completed')";
      }
    }

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
        m.quiz_percent AS "quizPercent",
        m.created_at AS "createdAt",
        m.updated_at AS "updatedAt",
        other_user.id AS "otherUserId",
        other_user.email AS "otherUserEmail",
        other_user.full_name AS "otherUserFullName",
        other_profile.bio AS "otherUserBio"
       FROM matches m
       JOIN users other_user
        ON other_user.id = CASE
          WHEN m.user_id_1 = $1 THEN m.user_id_2
          ELSE m.user_id_1
        END
       LEFT JOIN profiles other_profile ON other_profile.user_id = other_user.id
       WHERE (m.user_id_1 = $1 OR m.user_id_2 = $1)${modeClause}${visibilityClause}
       ORDER BY m.updated_at DESC`,
      params
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
      quizPercent: row.quizPercent,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      otherUser: {
        id: row.otherUserId,
        email: row.otherUserEmail,
        fullName: row.otherUserFullName,
        bio: row.otherUserBio
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