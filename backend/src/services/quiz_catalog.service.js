const fs = require("fs");
const path = require("path");

const QUESTION_COUNT = 5;
const CATALOG_PATH = path.join(__dirname, "../../data/quiz_catalog.json");
const MAX_RANDOM = 0x7fffffff;

let catalogCache = null;

// Dart Random — frontend LiveQuizSession ile aynı soru seçimi.
class DartRandom {
  constructor(seed) {
    this._state = seed & MAX_RANDOM;
  }

  next(bits) {
    this._state = (Math.imul(0x1bca794b, this._state) + 1) & MAX_RANDOM;
    return this._state >> (31 - bits);
  }

  nextInt(max) {
    if (max <= 0) {
      throw new Error("max must be positive");
    }
    if (max > MAX_RANDOM) {
      return this.nextInt(Math.floor(max / 2)) + this.nextInt(Math.ceil(max / 2));
    }
    let rnd;
    do {
      rnd = this.next(31);
    } while (rnd >= MAX_RANDOM - (MAX_RANDOM % max));
    return rnd % max;
  }
}

const stableHash = (input) => {
  let hash = 0x811c9dc5;
  for (let i = 0; i < input.length; i += 1) {
    hash ^= input.charCodeAt(i);
    hash = Math.imul(hash, 0x01000193) >>> 0;
  }
  return hash;
};

const loadCatalog = () => {
  if (catalogCache) return catalogCache;
  const raw = fs.readFileSync(CATALOG_PATH, "utf8");
  const json = JSON.parse(raw);
  catalogCache = json.categories || {};
  return catalogCache;
};

// frontend LiveQuizSession.questionsFor ile aynı mantık.
const selectQuestionsForMatch = (matchId, commonInterestIds = []) => {
  const catalog = loadCatalog();
  const interests = commonInterestIds
    .filter((id) => Array.isArray(catalog[id]))
    .sort();
  const source =
    interests.length > 0 ? interests : Object.keys(catalog).sort();

  const pool = [];
  for (const interestId of source) {
    for (const question of catalog[interestId]) {
      pool.push({
        interestId,
        questionId: String(question.id),
        key: `${interestId}:${question.id}`,
        text: question.text,
        options: question.options || []
      });
    }
  }

  if (pool.length <= QUESTION_COUNT) {
    return pool;
  }

  const rng = new DartRandom(stableHash(String(matchId)));
  const indices = new Set();
  while (indices.size < QUESTION_COUNT) {
    indices.add(rng.nextInt(pool.length));
  }

  return [...indices]
    .sort((a, b) => a - b)
    .map((i) => pool[i]);
};

module.exports = {
  QUESTION_COUNT,
  selectQuestionsForMatch
};
