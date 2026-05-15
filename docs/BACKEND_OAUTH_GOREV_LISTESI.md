# VEXA — Backend / OAuth görev listesi (arkadaş için)

**Kime:** Backend + Render + Supabase sorumlusu  
**Kimden:** Selçuk (Flutter / frontend)  
**Tarih:** Mayıs 2026  
**Amaç:** Mobil uygulama **sadece Google ve Apple** ile giriş yapsın; e-posta/şifre UI yok. Frontend hazır; production API’nin buna uyumlu olması gerekiyor.

---

## 1. Durum özeti

| Konu | Durum |
|------|--------|
| Production API | `https://vexa-backend-umg2.onrender.com/api` çalışıyor |
| Mevcut auth | Sadece `POST /auth/register` ve `POST /auth/login` (e-posta + şifre) |
| **Eksik (canlıda yok)** | `POST /auth/google`, `POST /auth/apple` |
| Flutter frontend | Google/Apple butonları → bu endpoint’lere istek atacak şekilde kodlandı |
| Cihaz (BLE) | Şimdilik yok; mock ekran yeterli |

**Kontrol:** Şu an production’da:

```bash
curl -X POST https://vexa-backend-umg2.onrender.com/api/auth/google \
  -H "Content-Type: application/json" \
  -d '{"idToken":"test"}'
```

Yanıt: `Cannot POST /api/auth/google` → endpoint henüz deploy edilmemiş.

---

## 2. Git akışı (önemli)

Selçuk’un makinesinde **commit edilmemiş** backend + frontend değişiklikleri var. İki yol:

### Yol A — Selçuk önce push eder (tercih)

1. Selçuk `dev` branch’ine commit + push yapar.  
2. Sen: `git pull origin dev`  
3. Backend OAuth kodunu review edip Render’a deploy edersin.

### Yol B — Sen sıfırdan eklersin

Selçuk push etmeden sen aşağıdaki **Bölüm 4** API sözleşmesine göre endpoint’leri yazarsın.

**Selçuk tarafı:** Backend’e dokunmadan önce mutlaka `git pull origin dev` yapmalı; aksi halde conflict olur.

---

## 3. Senin yapman gerekenler (checklist)

### 3.1 Kod

- [ ] `dev` branch’ini güncelle: `git pull origin dev`
- [ ] Backend’de OAuth route’ları olsun (aşağı Bölüm 4)
- [ ] Yeni npm paketleri:
  ```bash
  cd backend
  npm install google-auth-library apple-signin-auth
  ```
- [ ] Dosya: `backend/src/services/oauth_user.service.js`  
  - OAuth kullanıcısı e-posta ile bul / yoksa oluştur  
  - JWT üret (`JWT_SECRET`, örn. `7d` süre)
- [ ] `backend/.env.example` içinde:
  ```env
  GOOGLE_CLIENT_ID=
  APPLE_CLIENT_ID=
  ```
- [ ] `docs/api_contract.md` → `POST /auth/google` ve `POST /auth/apple` ekle

### 3.2 Render (production)

- [ ] Service: mevcut `vexa-backend` (veya eşdeğeri)
- [ ] **Environment variables:**
  | Değişken | Açıklama |
  |----------|----------|
  | `JWT_SECRET` | Zaten var — değiştirme |
  | `DATABASE_URL` | Supabase — zaten var |
  | `GOOGLE_CLIENT_ID` | Google Cloud OAuth **Web** veya iOS client ID (doğrulama için) |
  | `APPLE_CLIENT_ID` | Apple Services ID (Sign in with Apple) |
- [ ] Deploy (push sonrası otomatik veya Manual Deploy)
- [ ] Health check:
  ```bash
  curl https://vexa-backend-umg2.onrender.com/api/health
  ```

### 3.3 Google Cloud Console

- [ ] Proje oluştur / mevcut projeyi kullan
- [ ] OAuth consent screen (External, test users)
- [ ] OAuth Client ID’ler:
  - **iOS** (Bundle ID: Flutter `Runner` ile aynı)
  - **Android** (SHA-1 debug + release)
  - **Web** (Chrome test + gerekirse backend doğrulama)
- [ ] `GOOGLE_CLIENT_ID` → Render’a yapıştır (genelde **Web client ID** backend verify için kullanılır)

### 3.4 Apple Developer

- [ ] App ID → **Sign in with Apple** capability
- [ ] Services ID oluştur → `APPLE_CLIENT_ID` olarak Render’a ekle
- [ ] Selçuk’a Services ID ve gerekli Xcode capability notunu ilet

### 3.5 Doğrulama (deploy sonrası)

- [ ] `POST /auth/google` artık 404 değil (geçersiz token → 401 kabul)
- [ ] `POST /auth/apple` aynı şekilde
- [ ] Geçerli Google idToken ile JWT dönüyor
- [ ] `GET /users/me` + `Authorization: Bearer <token>` çalışıyor
- [ ] Selçuk’a yaz: **“OAuth canlı, test edebilirsin”**

---

## 4. API sözleşmesi (eklenecek endpoint’ler)

### POST /auth/google

**URL:** `/api/auth/google`

**Body:**

```json
{
  "idToken": "<Google Sign-In idToken>"
}
```

**Başarı (200):**

```json
{
  "success": true,
  "data": {
    "token": "<jwt>",
    "user": {
      "id": "<uuid>",
      "email": "user@gmail.com",
      "fullName": "Ad Soyad"
    }
  }
}
```

**Mantık:**

1. `google-auth-library` ile `idToken` doğrula (`GOOGLE_CLIENT_ID` audience).  
2. E-posta + isim al.  
3. `users` tablosunda e-posta ara; yoksa oluştur (`password_hash` = rastgele bcrypt, OAuth hesabı).  
4. JWT döndür (format mevcut `/auth/login` ile aynı).

**Hatalar:**

| Kod | message |
|-----|---------|
| 400 | idToken is required |
| 503 | Google sign-in is not configured on the server |
| 401 | Google sign-in failed |

---

### POST /auth/apple

**URL:** `/api/auth/apple`

**Body:**

```json
{
  "identityToken": "<Apple identity token>",
  "email": "user@privaterelay.appleid.com",
  "fullName": "Ad Soyad"
}
```

`email` ve `fullName` ilk girişte gelir; sonraki girişlerde boş olabilir — o zaman token içinden veya DB’deki kayıttan al.

**Başarı:** Google ile aynı `{ token, user }` yapısı.

**Mantık:**

1. `apple-signin-auth` ile `identityToken` doğrula (`APPLE_CLIENT_ID` audience).  
2. E-posta zorunlu (yoksa 400).  
3. Kullanıcı bul/oluştur + JWT.

---

## 5. Mevcut endpoint’ler (değişmeden kalsın)

Frontend bunları **token ile** kullanıyor:

| Method | Path | Kullanım |
|--------|------|----------|
| GET | `/users/me` | Açılışta profil çek |
| PUT | `/users/me/profile` | Profil kaydet (bio içinde geniş JSON — geçici) |
| PUT | `/users/me/avatar` | `avatarId` (UUID, `GET /avatars` listesinden) |
| PUT | `/users/me/mode` | `social` veya `networking` |
| GET | `/avatars` | Avatar listesi |
| GET | `/health` | Sağlık kontrolü |

**Not:** Flutter şu an `bio` alanına `VEXA_PROFILE_V1:{...json}` yazıyor (isim, soyisim, doğum tarihi, sosyal/network profiller). İleride ayrı kolonlara taşınabilir; şimdilik kırma.

---

## 6. Selçuk’un yapacakları (sen deploy ettikten sonra)

1. `git pull origin dev`  
2. Sadece `frontend/` üzerinde çalışmaya devam  
3. Google/Apple client ID’leri plist / Android config’e ekler (senden ID bekliyor)  
4. `flutter run` ile uçtan uca test  

**Selçuk backend’e PR atmamalı** — OAuth ve Render sende kalsın, conflict azalır.

---

## 7. Referans kod (Selçuk’un yerel branch’inde)

Push edilirse bu dosyalar gelir:

```text
backend/src/routes/auth.routes.js          → /google, /apple route’ları
backend/src/services/oauth_user.service.js → findOrCreate + JWT
backend/package.json                       → google-auth-library, apple-signin-auth
```

İncelemek için Selçuk push sonrası diff:

```bash
git log -1 --oneline
git show --stat HEAD
```

---

## 8. İletişim

Deploy bitince Selçuk’a şunları yaz:

1. `GOOGLE_CLIENT_ID` (mobil config için hangi client: iOS / Web)  
2. `APPLE_CLIENT_ID` (Services ID)  
3. “Production’da `/auth/google` ve `/auth/apple` hazır”  
4. Varsa test kullanıcı e-postası (Google consent test mode)

---

## 9. Özet (tek cümle)

**Google ve Apple idToken doğrulayıp JWT dönen iki endpoint’i yaz, Render env’e client ID’leri koy, deploy et; Selçuk pull edip sadece Flutter test edecek.**
