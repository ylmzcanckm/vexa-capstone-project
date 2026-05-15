const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { OAuth2Client } = require("google-auth-library");
const appleSignin = require("apple-signin-auth");

const db = require("../config/db");
const {
  findOrCreateOAuthUser,
  issueToken
} = require("../services/oauth_user.service");

const router = express.Router();

const googleClient = process.env.GOOGLE_CLIENT_ID
  ? new OAuth2Client(process.env.GOOGLE_CLIENT_ID)
  : null;

router.post("/register", async (req, res) => {
  try {
    const { email, password, fullName } = req.body;

    if (!email || !password || !fullName) {
      return res.status(400).json({
        success: false,
        message: "Email, password and fullName are required"
      });
    }

    const existingUser = await db.query(
      "SELECT id FROM users WHERE email = $1",
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({
        success: false,
        message: "Email already exists"
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await db.query(
      `INSERT INTO users (email, password_hash, full_name)
       VALUES ($1, $2, $3)
       RETURNING id, email, full_name AS "fullName", created_at AS "createdAt"`,
      [email, hashedPassword, fullName]
    );

    res.status(201).json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error("Register failed:", error);

    res.status(500).json({
      success: false,
      message: "Register failed"
    });
  }
});

router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required"
      });
    }

    const result = await db.query(
      `SELECT 
        id,
        email,
        password_hash AS "passwordHash",
        full_name AS "fullName"
       FROM users
       WHERE email = $1`,
      [email]
    );

    const user = result.rows[0];

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password"
      });
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password"
      });
    }

    const token = jwt.sign(
      {
        userId: user.id,
        email: user.email
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "1h"
      }
    );

    res.json({
      success: true,
      data: {
        token,
        user: {
          id: user.id,
          email: user.email,
          fullName: user.fullName
        }
      }
    });
  } catch (error) {
    console.error("Login failed:", error);

    res.status(500).json({
      success: false,
      message: "Login failed"
    });
  }
});

router.post("/google", async (req, res) => {
  try {
    const { idToken, accessToken } = req.body;

    if (!idToken && !accessToken) {
      return res.status(400).json({
        success: false,
        message: "idToken or accessToken is required"
      });
    }

    if (!googleClient || !process.env.GOOGLE_CLIENT_ID) {
      return res.status(503).json({
        success: false,
        message: "Google sign-in is not configured on the server"
      });
    }

    let email;
    let fullName;

    if (idToken) {
      const ticket = await googleClient.verifyIdToken({
        idToken,
        audience: process.env.GOOGLE_CLIENT_ID
      });
      const payload = ticket.getPayload();
      email = payload?.email;
      fullName = payload?.name;
    } else {
      // Flutter Web çoğu zaman idToken yerine accessToken verir.
      const tokenInfo = await googleClient.getTokenInfo(accessToken);
      email = tokenInfo.email;
      fullName = tokenInfo.name;
    }

    if (!email) {
      return res.status(401).json({
        success: false,
        message: "Google account email is missing"
      });
    }

    const user = await findOrCreateOAuthUser(email, fullName || email);
    const session = issueToken(user);

    res.json({ success: true, data: session });
  } catch (error) {
    console.error("Google auth failed:", error);
    res.status(401).json({
      success: false,
      message: "Google sign-in failed"
    });
  }
});

router.post("/apple", async (req, res) => {
  try {
    const { identityToken, email: bodyEmail, fullName: bodyFullName } = req.body;

    if (!identityToken) {
      return res.status(400).json({
        success: false,
        message: "identityToken is required"
      });
    }

    if (!process.env.APPLE_CLIENT_ID) {
      return res.status(503).json({
        success: false,
        message: "Apple sign-in is not configured on the server"
      });
    }

    const claims = await appleSignin.verifyIdToken(identityToken, {
      audience: process.env.APPLE_CLIENT_ID,
      ignoreExpiration: false
    });

    const email = bodyEmail || claims.email;

    if (!email) {
      return res.status(400).json({
        success: false,
        message:
          "Apple email is unavailable. Sign in again and allow email sharing."
      });
    }

    const user = await findOrCreateOAuthUser(email, bodyFullName || email);
    const session = issueToken(user);

    res.json({ success: true, data: session });
  } catch (error) {
    console.error("Apple auth failed:", error);
    res.status(401).json({
      success: false,
      message: "Apple sign-in failed"
    });
  }
});

module.exports = router;