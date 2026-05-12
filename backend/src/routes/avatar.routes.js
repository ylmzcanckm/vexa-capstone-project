const express = require("express");

const router = express.Router();

const avatars = [
  {
    id: "avatar_1",
    name: "Blue Avatar",
    imageUrl: "https://example.com/avatar1.png"
  },
  {
    id: "avatar_2",
    name: "Green Avatar",
    imageUrl: "https://example.com/avatar2.png"
  },
  {
    id: "avatar_3",
    name: "Purple Avatar",
    imageUrl: "https://example.com/avatar3.png"
  }
];

router.get("/", (req, res) => {
  res.json({
    success: true,
    data: avatars
  });
});

module.exports = router;