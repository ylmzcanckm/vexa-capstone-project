# Google giriş — iOS kurulumu

## Hata

`Custom scheme URIs are not allowed for 'WEB' client type` (400)

**Sebep:** iPhone'da **Web** OAuth Client ID kullanılmış. iOS için ayrı **iOS** client gerekir.

## 5 dakikalık kurulum

### 1. Google Cloud Console

1. [Google Cloud Console → Credentials](https://console.cloud.google.com/apis/credentials)
2. **Create Credentials** → **OAuth client ID**
3. Application type: **iOS**
4. Bundle ID: `com.selcukbuyukpoyraz.vexa` (Xcode ile aynı)
5. **Create** → Client ID'yi kopyala (ör. `74651460819-xxxxx.apps.googleusercontent.com`)

### 2. Flutter projesi

```bash
cd frontend
chmod +x tool/sync_google_ios_plist.sh
./tool/sync_google_ios_plist.sh 74651460819-BURAYA_IOS_SUFFIX.apps.googleusercontent.com
```

Bu komut `app_config.dart` ve `ios/Runner/Info.plist` dosyalarını günceller.

### 3. Telefona yükle

```bash
./tool/ios_run_device.sh
```

## Backend

Render'daki `GOOGLE_CLIENT_ID` **Web** client olarak kalır (değiştirme).

iOS uygulaması:

- `clientId` → **iOS** client
- `serverClientId` → **Web** client (idToken backend'de doğrulanır)

## Arkadaş

Eğer Console'da zaten iOS client varsa (eski bundle `com.example.vexa` ile oluşturulmuş olabilir), ya yeni iOS client ekle (`com.selcukbuyukpoyraz.vexa`) ya da bundle ID'yi eşleştir.
