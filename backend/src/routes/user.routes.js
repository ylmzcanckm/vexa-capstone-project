const express = require("express");

const authMiddleware = require("../middlewares/auth.middleware");
const { users, profiles, userSettings } = require("../models/memoryStore");

const router = express.Router();

router.get("/me", authMiddleware, (req, res) => {
  const user = users.find((item) => item.id === req.user.userId);

  if (!user) {
    return res.status(404).json({
      success: false,
      message: "User not found"
    });
  }

  const profile = profiles.find((item) => item.userId === user.id) || null;
  const settings = userSettings.find((item) => item.userId === user.id) || null;

  res.json({
    success: true,
    data: {
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      profile,
      settings
    }
  });
});

router.put("/me/profile", authMiddleware, (req, res) => {
  const { bio, interests, personalityTags } = req.body;

  let profile = profiles.find((item) => item.userId === req.user.userId);

  if (!profile) {
    profile = {
      userId: req.user.userId,
      bio: bio || "",
      interests: interests || [],
      personalityTags: personalityTags || [],
      updatedAt: new Date().toISOString()
    };

    profiles.push(profile);
  } else {
    profile.bio = bio || profile.bio;
    profile.interests = interests || profile.interests;
    profile.personalityTags = personalityTags || profile.personalityTags;
    profile.updatedAt = new Date().toISOString();
  }

  res.json({
    success: true,
    data: profile
  });
});

router.put("/me/avatar", authMiddleware, (req, res) => {
  const { avatarId } = req.body;

  if (!avatarId) {
    return res.status(400).json({
      success: false,
      message: "avatarId is required"
    });
  }

  let settings = userSettings.find((item) => item.userId === req.user.userId);

  if (!settings) {
    settings = {
      userId: req.user.userId,
      selectedAvatarId: avatarId,
      selectedMode: null,
      isAvailable: true,
      updatedAt: new Date().toISOString()
    };

    userSettings.push(settings);
  } else {
    settings.selectedAvatarId = avatarId;
    settings.updatedAt = new Date().toISOString();
  }

  res.json({
    success: true,
    data: settings
  });
});

router.put("/me/mode", authMiddleware, (req, res) => {
  const { mode } = req.body;

  const allowedModes = ["social", "networking"];

  if (!mode || !allowedModes.includes(mode)) {
    return res.status(400).json({
      success: false,
      message: "mode must be either social or networking"
    });
  }

  let settings = userSettings.find((item) => item.userId === req.user.userId);

  if (!settings) {
    settings = {
      userId: req.user.userId,
      selectedAvatarId: null,
      selectedMode: mode,
      isAvailable: true,
      updatedAt: new Date().toISOString()
    };

    userSettings.push(settings);
  } else {
    settings.selectedMode = mode;
    settings.updatedAt = new Date().toISOString();
  }

  res.json({
    success: true,
    data: settings
  });
});

module.exports = router;