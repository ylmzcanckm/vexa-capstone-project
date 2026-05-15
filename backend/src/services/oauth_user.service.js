const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const db = require("../config/db");

async function findOrCreateOAuthUser(email, fullName) {
  const existing = await db.query(
    `SELECT id, email, full_name AS "fullName"
     FROM users WHERE email = $1`,
    [email]
  );

  if (existing.rows.length > 0) {
    return existing.rows[0];
  }

  const placeholderHash = await bcrypt.hash(`oauth:${email}:${Date.now()}`, 10);
  const inserted = await db.query(
    `INSERT INTO users (email, password_hash, full_name)
     VALUES ($1, $2, $3)
     RETURNING id, email, full_name AS "fullName"`,
    [email, placeholderHash, fullName || email.split("@")[0]]
  );

  return inserted.rows[0];
}

function issueToken(user) {
  const token = jwt.sign(
    { userId: user.id, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: "7d" }
  );

  return {
    token,
    user: {
      id: user.id,
      email: user.email,
      fullName: user.fullName
    }
  };
}

module.exports = {
  findOrCreateOAuthUser,
  issueToken
};
