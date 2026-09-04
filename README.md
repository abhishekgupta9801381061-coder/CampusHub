# CampusHub 🛡️🎓
### Privacy-First Private Campus Network Exclusively for University Freshmen

**CampusHub** is a production-ready mobile application built for 1st-year university students to find hackathon & project teammates, discover competitions, trade academic supplies, join collaboration squads, share anonymous confessions, and safely exchange contact information without exposing private personal details.

---

## 🔒 10 Non-Negotiable Privacy Guarantees (Architectural Implementation)

| Rule | Guarantee | Implementation Point |
|---|---|---|
| **1** | Phone number NOT required for registration | Excluded from mandatory signup schema; optional for ephemeral link sharing only. |
| **2** | Email NOT required for registration | Registration authenticates via `@handle` and university `Roll No`. |
| **3** | Exact room number NEVER collected or displayed | Entire model hierarchy (`User`, `PartnerRequest`, `GroupMember`, `ExchangeListing`) and UI enforce **Hostel name only**. |
| **4** | Public profiles display Hostel name only | Public profile view `public_user_profiles` strictly limits metadata. |
| **5** | Personal contact hidden by default | Instagram, LinkedIn, and WhatsApp contacts are hidden behind the Ephemeral Social Bridge. |
| **6** | Social contact shared via temporary links | `SocialBridgeRepository` produces expiring tokens (1 hr, 24 hrs, 7 days) with instant revocation. |
| **7** | Security-question password recovery | Zero mandatory SMS/email recovery; verified with salted SHA-256 hash comparison. |
| **8** | Ghost Mode | One-tap toggle instantly omits user from `discoverStudentsProvider` and search queries. |
| **9** | Promotional feature consent | Explicit toggle with confirmation dialog required before achievements appear on highlights. |
| **10** | Zero sensitive data logging | `AppLogger` regex sanitizer strips passwords, security answers, and session tokens. |

---

## ⚡ Server-Ready Rate Limits & Business Rules

1. **Partner Requests**:
   - **Max 1 request per calendar day** (Enforced in `MockPartnerRequestRepository.canUserCreateToday` and PostgreSQL trigger `trg_check_daily_partner_request_limit`).
   - **Max 3 edits per calendar day** (`check_daily_partner_request_edit_limit`).
   - **Auto-expires after 5 days** (`PartnerRequest.isExpired` countdown timer).
   - User can delete request at any time.
2. **Collaboration Groups**:
   - **Max 4 active groups created per user** (`MockGroupRepository.getUserCreatedGroupCount` and SQL trigger `trg_check_max_active_groups_limit`).
3. **Anonymous Campus Confessions**:
   - 100% unlinked author identity. Post deletion is authenticated via a cryptographic client token (`authorSecret`).

---

## 📁 Feature-First Clean Architecture

```
lib/
├── app.dart                               # MaterialApp.router with light & dark theme
├── main.dart                              # ProviderScope and entry point
├── core/
│   ├── constants/                         # Colors, business rules, university data, strings
│   ├── errors/                            # Failures & exceptions
│   ├── network/                           # Dio ApiClient with token injection & error mapper
│   ├── router/                            # GoRouter stateful shell navbar & sub-routes
│   ├── theme/                             # Material 3 light/dark AppTheme
│   ├── utils/                             # Input validators, security utils, date formatter
│   └── widgets/                           # Reusable AppButton, AppTextField, AppCard, Avatar
└── features/
    ├── auth/                              # User, AuthRepository, AuthScreen, ForgotPassword
    ├── home/                              # Freshman Dashboard & highlights
    ├── profile/                           # Profile, Discover, Edit Profile, Settings
    ├── partner_requests/                  # 1/day, 3 edits/day, 5-day expiry countdown
    ├── groups/                            # Collaboration squads, 4-group limit
    ├── contests/                          # Hackathons, deadlines, prize pools, bookmarking
    ├── confessions/                       # Anonymous category feed, voting, threaded comments
    ├── exchange/                          # Textbooks & lab coats trade (hostel only)
    ├── achievements/                      # Verified achievements & signed URL workflow
    ├── social_bridge/                     # Ephemeral revocable contact sharing
    └── ghost_mode/                        # Real-time search invisibility
```

---

## 🚀 Getting Started & Local Run Instructions

### Prerequisites
- **Flutter SDK**: 3.10.x or higher
- **Dart SDK**: 3.0.x or higher
- **Android Studio** (for Android SDK & Emulator) or **Xcode** (for iOS Simulator)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App
To run in debug mode on your connected device, emulator, or Chrome:
```bash
# Run on default connected device / emulator
flutter run

# Run on Chrome for instant web preview
flutter run -d chrome
```

---

## 📱 Platform Specific Configuration

### Android Setup
1. Minimum SDK version is set to `21` (Android 5.0 Lollipop) and Target SDK is `34` in [build.gradle](file:///c:/Users/abhis/OneDrive/Desktop/CampusHub/android/app/build.gradle).
2. Permissions configured in [AndroidManifest.xml](file:///c:/Users/abhis/OneDrive/Desktop/CampusHub/android/app/src/main/AndroidManifest.xml):
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
   ```

### iOS Setup
1. Target iOS version is `13.0+`.
2. Ensure CocoaPods is installed:
   ```bash
   cd ios
   pod install
   cd ..
   ```

---

## 🧪 Automated Testing Suite

CampusHub includes unit tests verifying all 11 required critical business rules:
```bash
flutter test
```

Specific test suites:
```bash
# 1-5: Partner request rate limits, daily limits, 5-day expiry, delete
flutter test test/unit/partner_request_rules_test.dart

# 6: 4 active groups limit
flutter test test/unit/groups_rules_test.dart

# 7-11: Room number privacy, Ghost mode, anonymity, password sanitizer, auth exceptions
flutter test test/unit/privacy_rules_test.dart

# Widget test: Segmented login & sign-up tabs
flutter test test/widget/auth_screen_test.dart
```

---

## 🗄️ Backend Integration (Supabase / REST / Redis)

1. Open your **Supabase Dashboard** or standard PostgreSQL instance.
2. Open the SQL Editor and execute [backend/schema.sql](file:///c:/Users/abhis/OneDrive/Desktop/CampusHub/backend/schema.sql).
3. The SQL script will create all tables, indexes, triggers enforcing rate limits, and Row Level Security (RLS) policies.
4. To switch from `MockAuthRepository` to live Supabase, update the providers in `auth_providers.dart`, `partner_request_providers.dart`, etc., to instantiate your REST/Supabase repository implementations.

---

## 📦 Production Build Commands

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS Bundle
flutter build ipa --release
```
