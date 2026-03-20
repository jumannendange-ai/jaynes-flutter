# JAYNES MAX TV - Flutter App

## Build Kutoka Termux

```bash
# 1. Hakikisha Flutter ipo
flutter --version

# 2. Weka dependencies
flutter pub get

# 3. Build APK
flutter build apk --release

# APK itakuwa hapa:
# build/app/outputs/flutter-apk/app-release.apk
```

## Push kwenda GitHub

```bash
git init
git remote add origin https://TOKEN@github.com/jumannendange-ai/jaynes-flutter.git
git add .
git commit -m "JAYNES MAX TV Flutter v5.0"
git push -u origin main
```

## Maelezo ya Folders

- `lib/screens/` - Screens zote (Home, Player, Live, Auth, Account)
- `lib/services/` - API calls (pixtvmax, azam, channels.php, auth.php)
- `lib/models/` - Channel, SubscriptionPlan models
- `lib/utils/` - Constants (API URLs, ClearKeys), AppTheme
- `android/` - Android configuration

## APIs Zilizounganishwa

| Screen | API |
|--------|-----|
| Home | pixtvmax.quest + azam.php (Azam Sports 1-4) |
| Live | channels.php (mechi za leo) |
| Categories | categories.php |
| Account | auth.php + malipo kwa WhatsApp |
| Player | ExoPlayer via media_kit + ClearKey DRM |

## Muhimu

Badilisha `android/app/google-services.json` na file halisi kutoka Firebase Console ya `jaynes-tv-c1119`.
