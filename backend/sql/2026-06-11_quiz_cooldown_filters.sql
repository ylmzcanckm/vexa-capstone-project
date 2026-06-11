-- VEXA — Canlı quiz + 2 saatlik eşleşme molası + tanışma filtreleri
-- Supabase: SQL Editor → bu dosyanın tamamını yapıştır → Run
-- Tüm komutlar idempotent (IF NOT EXISTS) — iki kez çalıştırmak sorun olmaz.

-- 1) Canlı quiz cevapları (eşleşme + kullanıcı başına bir satır)
CREATE TABLE IF NOT EXISTS match_quiz_answers (
  match_id   UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  answers    JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (match_id, user_id)
);

-- 2) Quiz sonucu match kaydının üstünde
ALTER TABLE matches ADD COLUMN IF NOT EXISTS quiz_percent INTEGER;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS quiz_completed_at TIMESTAMPTZ;

-- 3) 2 saatlik eşleşme molası (kullanıcı bazlı, quiz bitince yazılır)
CREATE TABLE IF NOT EXISTS match_cooldowns (
  user_id        UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  cooldown_until TIMESTAMPTZ NOT NULL,
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 4) Tanışma filtrelerinin sunucu kopyası
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS discovery_filters JSONB;
