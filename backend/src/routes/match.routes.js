const express = require("express");

const authMiddleware = require("../middlewares/auth.middleware");
const {
  users,
  profiles,
  userSettings,
  matches
} = require("../models/memoryStore");

const router = express.Router();

const getCommonItems = (firstList = [], secondList = []) => {
  return firstList.filter((item) => secondList.includes(item));
};

router.get("/candidates", authMiddleware, (req, res) => {
  const candidates = users
    .filter((user) => user.id !== req.user.userId)
    .map((user) => {
      const profile = profiles.find((item) => item.userId === user.id) || null;
      const settings =
        userSettings.find((item) => item.userId === user.id) || null;

      return {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        profile,
        settings
      };
    });

  res.json({
    success: true,
    data: candidates
  });
});

router.post("/check", authMiddleware, (req, res) => {
  const { targetUserId, targetEmail } = req.body;

  const currentUser = users.find((user) => user.id === req.user.userId);

  if (!currentUser) {
    return res.status(404).json({
      success: false,
      message: "Current user not found"
    });
  }

  const targetUser = users.find((user) => {
    return user.id === targetUserId || user.email === targetEmail;
  });

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

  const currentProfile =
    profiles.find((profile) => profile.userId === currentUser.id) || {};
  const targetProfile =
    profiles.find((profile) => profile.userId === targetUser.id) || {};

  const currentSettings =
    userSettings.find((settings) => settings.userId === currentUser.id) || {};
  const targetSettings =
    userSettings.find((settings) => settings.userId === targetUser.id) || {};

  const commonInterests = getCommonItems(
    currentProfile.interests || [],
    targetProfile.interests || []
  );

  const commonPersonalityTags = getCommonItems(
    currentProfile.personalityTags || [],
    targetProfile.personalityTags || []
  );

  const sameMode =
    currentSettings.selectedMode &&
    targetSettings.selectedMode &&
    currentSettings.selectedMode === targetSettings.selectedMode;

  const score = Math.min(
    100,
    commonInterests.length * 25 +
      commonPersonalityTags.length * 15 +
      (sameMode ? 20 : 0)
  );

  const isMatch = score >= 50;

  const existingMatch = matches.find((match) => {
    const sameDirection =
      match.userId1 === currentUser.id && match.userId2 === targetUser.id;

    const reverseDirection =
      match.userId1 === targetUser.id && match.userId2 === currentUser.id;

    return sameDirection || reverseDirection;
  });

  if (existingMatch) {
    existingMatch.matchScore = score;
    existingMatch.commonInterests = commonInterests;
    existingMatch.commonPersonalityTags = commonPersonalityTags;
    existingMatch.sameMode = Boolean(sameMode);
    existingMatch.status = isMatch ? "detected" : "not_matched";
    existingMatch.updatedAt = new Date().toISOString();

    return res.json({
      success: true,
      data: existingMatch
    });
  }

  const newMatch = {
    id: `match_${matches.length + 1}`,
    userId1: currentUser.id,
    userId2: targetUser.id,
    matchScore: score,
    commonInterests,
    commonPersonalityTags,
    sameMode: Boolean(sameMode),
    mode: currentSettings.selectedMode || null,
    status: isMatch ? "detected" : "not_matched",
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };

  matches.push(newMatch);

  res.status(201).json({
    success: true,
    data: newMatch
  });
});

router.get("/history", authMiddleware, (req, res) => {
  const userMatches = matches
    .filter((match) => {
      return match.userId1 === req.user.userId || match.userId2 === req.user.userId;
    })
    .map((match) => {
      const otherUserId =
        match.userId1 === req.user.userId ? match.userId2 : match.userId1;

      const otherUser = users.find((user) => user.id === otherUserId);

      return {
        ...match,
        otherUser: otherUser
          ? {
              id: otherUser.id,
              email: otherUser.email,
              fullName: otherUser.fullName
            }
          : null
      };
    });

  res.json({
    success: true,
    data: userMatches
  });
});

module.exports = router;