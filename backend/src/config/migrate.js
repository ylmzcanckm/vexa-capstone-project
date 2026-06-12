const fs = require("fs");
const path = require("path");

const db = require("./db");

const MIGRATION_FILES = ["2026-06-11_quiz_cooldown_filters.sql"];

const runMigrations = async () => {
  if (!process.env.DATABASE_URL) {
    console.warn("DATABASE_URL missing — skipping SQL migrations.");
    return;
  }

  for (const file of MIGRATION_FILES) {
    const sqlPath = path.join(__dirname, "../../sql", file);
    if (!fs.existsSync(sqlPath)) {
      console.warn(`Migration file not found: ${file}`);
      continue;
    }

    const sql = fs.readFileSync(sqlPath, "utf8");
    try {
      await db.query(sql);
      console.log(`Migration applied: ${file}`);
    } catch (error) {
      console.error(`Migration failed (${file}):`, error.message);
    }
  }
};

module.exports = { runMigrations };
