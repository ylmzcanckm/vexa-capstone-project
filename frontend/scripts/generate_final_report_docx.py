#!/usr/bin/env python3
"""Generate Selçuk's VEXA Final Report sections as a DOCX file."""

from pathlib import Path
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.style import WD_STYLE_TYPE

OUTPUT = Path("/Users/selcukbuyukpoyraz/Desktop/Selcuk_VEXA_FinalReport_Sections.docx")
SCREENSHOTS = Path("/Users/selcukbuyukpoyraz/Desktop/app screenshots")

FIGURES = [
    ("IMG_1587.PNG", "Figure 1. VEXA welcome and authentication screen with Google OAuth (production-ready) and Apple Sign-In UI (production deferred pending Apple Developer Program enrollment)."),
    ("IMG_1588.PNG", "Figure 2. Social mode home screen with discovery filters: age range slider and gender preference selection."),
    ("IMG_1589.PNG", "Figure 3. Extended discovery filters: height, weight, education level, smoking, and alcohol preferences."),
    ("IMG_1590.PNG", "Figure 4. Social profile view displaying personal attributes, avatar, and lifestyle fields."),
    ("IMG_1591.PNG", "Figure 5. Social profile detail screen with hobbies, bio, and ice-breaker question fields."),
    ("IMG_1592.PNG", "Figure 6. Social match history listing completed matches with quiz percentage and compatibility score."),
    ("IMG_1593.PNG", "Figure 7. Matched person card (Social mode) shown after quiz completion, displaying compatibility and quiz score."),
    ("IMG_1594.PNG", "Figure 8. Ghost mode: low-energy standby state with discovery disabled."),
    ("IMG_1595.PNG", "Figure 9. Ghost mode profile with minimal identity fields (name, surname, age only)."),
    ("IMG_1596.PNG", "Figure 10. Business (Networking) mode home screen with network card readiness indicator."),
    ("IMG_1597.PNG", "Figure 11. Business profile view with professional title, company, and location fields."),
    ("IMG_1598.PNG", "Figure 12. Business profile tags, collaboration interests, and elevator-pitch bio section."),
    ("IMG_1599.PNG", "Figure 13. LilyGO device settings: per-user BLE binding, vibration, brightness, and screen timeout controls."),
    ("IMG_1600.PNG", "Figure 14. Notification preferences: push, in-app, and match alert toggles."),
    ("IMG_1601.PNG", "Figure 15. Privacy and security settings including discovery visibility, email display, and KVKK consent status."),
    ("IMG_1602.PNG", "Figure 16. Accessibility settings: text size scaling and bold text toggle."),
    ("IMG_1603.PNG", "Figure 17. Account settings: dark mode, account deletion, KVKK form, and logout."),
    ("IMG_1604.PNG", "Figure 18. About VEXA screen showing application version 1.0.0+1 and project links."),
    ("IMG_1605.PNG", "Figure 19. VEXA Finder proximity matching screen with BLE scan toggle and LilyGO pairing status."),
    ("IMG_1606.PNG", "Figure 20. Block/hide list for local user exclusion from discovery (server sync planned)."),
    ("IMG_1607.PNG", "Figure 21. System permissions overview: Bluetooth, location (BLE scan), and notifications."),
]


def setup_styles(doc):
    styles = doc.styles
    if "Report Heading 1" not in [s.name for s in styles]:
        h1 = styles.add_style("Report Heading 1", WD_STYLE_TYPE.PARAGRAPH)
        h1.font.name = "Times New Roman"
        h1.font.size = Pt(14)
        h1.font.bold = True
        h1.font.color.rgb = RGBColor(0, 0, 0)
    if "Report Body" not in [s.name for s in styles]:
        body = styles.add_style("Report Body", WD_STYLE_TYPE.PARAGRAPH)
        body.font.name = "Times New Roman"
        body.font.size = Pt(12)
    if "Report Caption" not in [s.name for s in styles]:
        cap = styles.add_style("Report Caption", WD_STYLE_TYPE.PARAGRAPH)
        cap.font.name = "Times New Roman"
        cap.font.size = Pt(10)
        cap.font.italic = True


def add_heading(doc, text, level=1):
    p = doc.add_paragraph(text, style="Report Heading 1" if level == 1 else f"Heading {level}")
    if level == 1:
        p.paragraph_format.space_before = Pt(18)
        p.paragraph_format.space_after = Pt(6)
    return p


def add_body(doc, text):
    p = doc.add_paragraph(text, style="Report Body")
    p.paragraph_format.space_after = Pt(6)
    p.paragraph_format.line_spacing = 1.15
    return p


def add_bullet(doc, text):
    p = doc.add_paragraph(text, style="List Bullet")
    p.paragraph_format.space_after = Pt(3)
    for run in p.runs:
        run.font.name = "Times New Roman"
        run.font.size = Pt(12)
    return p


def add_figure(doc, filename, caption):
    img_path = SCREENSHOTS / filename
    if not img_path.exists():
        add_body(doc, f"[Image not found: {filename}]")
        return
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run()
    run.add_picture(str(img_path), width=Inches(2.8))
    cap = doc.add_paragraph(caption, style="Report Caption")
    cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
    cap.paragraph_format.space_after = Pt(12)


def build_document():
    doc = Document()
    setup_styles(doc)

    # Title page block
    title = doc.add_paragraph()
    title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = title.add_run("VEXA — Final Report Sections\n(Software Engineering / Mobile Frontend)\n")
    run.bold = True
    run.font.size = Pt(16)
    run.font.name = "Times New Roman"
    sub = doc.add_paragraph()
    sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    sr = sub.add_run("Author: Selçuk Büyükpoyraz\nDepartment: Software Engineering\nDate: June 2026")
    sr.font.size = Pt(12)
    sr.font.name = "Times New Roman"
    doc.add_page_break()

    # ── 3.2 System Design / Architecture ──
    add_heading(doc, "3.2 System Design and Architecture")
    add_body(doc,
        "The VEXA mobile client follows a layered, feature-oriented architecture implemented in Flutter (Dart). "
        "The application is structured into four primary layers: presentation (screens and widgets), domain "
        "(business rules and models), data (repositories, local stores, and BLE services), and core "
        "(API client, navigation, theme, and shared utilities). This separation ensures that UI concerns "
        "remain decoupled from networking, persistence, and hardware communication.")
    add_body(doc,
        "At the centre of the architecture sits a REST API client (ApiClient) that communicates with the "
        "deployed Node.js backend hosted on Render (https://vexa-backend-umg2.onrender.com/api). "
        "Authentication tokens are persisted locally via AuthTokenStore and injected into every authenticated "
        "request. User profiles, match history, quiz submissions, and discovery filter preferences are "
        "synchronised with the backend where applicable; purely local preferences (accessibility, theme, "
        "blocked users) are stored in SharedPreferences.")
    add_body(doc,
        "The mobile application supports three operational modes—Social, Ghost, and Business (Networking)—"
        "each with distinct profile schemas, discovery rules, and post-match flows. Mode selection is "
        "managed by ModeSelectionScreen with swipe-based navigation and mode-specific styling "
        "(VexaModeStyle). The LiveMatchWatcher service polls the backend for pending matches and routes "
        "the user to the appropriate screen: LiveQuizScreen for Social matches (quiz required, ≥80% pass "
        "threshold) or NetworkMatchScreen for Business matches (no quiz, direct person-card access).")
    add_body(doc,
        "Hardware integration is handled through a dedicated BLE subsystem. BleAvatarTransferService "
        "manages GATT communication with LilyGO wearable devices, while BoundLilygoStore enforces "
        "per-user device binding so that avatar bitmaps, clock displays, and match signals are sent "
        "only to the user's paired VEXA device. ProximityScanner and VexaFinderService perform periodic "
        "BLE scans (every 20 seconds) to detect nearby VEXA devices and trigger match workflows.")
    add_body(doc,
        "Figure 1 illustrates the entry point of the application, and Figures 2–12 demonstrate the "
        "mode-specific UI surfaces that compose the presentation layer.")
    add_figure(doc, *FIGURES[0])
    add_figure(doc, *FIGURES[1])

    # ── 3.3 Tools, Technologies, and Standards ──
    add_heading(doc, "3.3 Tools, Technologies, and Standards")
    add_body(doc, "The following tools, frameworks, and standards were employed throughout mobile development:")
    add_bullet(doc, "Flutter 3.x / Dart — cross-platform mobile framework targeting iOS (primary) and Android.")
    add_bullet(doc, "Riverpod — state management for providers (discovery filters, settings, device link state).")
    add_bullet(doc, "GoRouter — declarative navigation with deep-link support for match and quiz screens.")
    add_bullet(doc, "flutter_blue_plus — BLE scanning, connection, and GATT characteristic read/write for LilyGO devices.")
    add_bullet(doc, "flutter_compass — device compass heading for RSSI-based direction finding (Match Compass feature).")
    add_bullet(doc, "google_sign_in — OAuth 2.0 authentication with Google (production-ready).")
    add_bullet(doc, "sign_in_with_apple — Apple Sign-In UI implemented; production deployment deferred pending Apple Developer Program enrollment ($99/year).")
    add_bullet(doc, "shared_preferences — local key-value storage for tokens, device binding, filters, and user preferences.")
    add_bullet(doc, "DiceBear API — programmatic avatar generation (Dylan style) with manual customisation support.")
    add_bullet(doc, "REST / JSON — HTTP communication with the Node.js + Express backend and Supabase PostgreSQL database.")
    add_bullet(doc, "Git / GitHub — version control; CI via Render auto-deploy for backend.")
    add_bullet(doc, "Xcode / CocoaPods — iOS build toolchain; Info.plist configured with NSBluetoothAlwaysUsageDescription, NSLocationWhenInUseUsageDescription, and NSMotionUsageDescription.")
    add_bullet(doc, "Material Design 3 with custom VexaPalette dark theme — consistent visual language across all screens.")
    add_body(doc,
        "Coding standards follow Dart effective-style guidelines. The project uses a feature-first directory "
        "structure (features/auth, features/matching, features/device, etc.) with shared core utilities. "
        "API models are serialised manually with fromJson/toJson factories.")

    # ── 4.1 Development Process ──
    add_heading(doc, "4.1 Development Process")
    add_body(doc,
        "Development followed an iterative, MVP-driven process aligned with the project's Friday/Saturday "
        "demo milestone. Work was organised in two-week sprints with daily stand-ups and shared GitHub "
        "repository access. The mobile frontend was developed in parallel with the backend (Can) and "
        "firmware (LilyGO) teams, with integration points defined early.")
    add_body(doc, "Key process stages:")
    add_bullet(doc, "Requirements analysis — mode-specific flows (Social quiz vs. Network direct match), discovery filters, and BLE protocol defined collaboratively.")
    add_bullet(doc, "UI/UX prototyping — dark-themed screens designed in Flutter with mode-specific colour accents (purple for Social, grey-blue for Ghost, cyan for Business).")
    add_bullet(doc, "Incremental implementation — authentication → profile creation → mode selection → matching → quiz → history → device binding → proximity finder.")
    add_bullet(doc, "Integration testing — two physical iPhones and three LilyGO devices used for end-to-end validation.")
    add_bullet(doc, "Bug fixing and refinement — Info.plist Bluetooth key correction, per-user device binding to prevent cross-device avatar transfer, mode-isolated history filtering.")
    add_body(doc,
        "Version control followed a dev-branch workflow. Features were developed on feature branches and "
        "merged into dev after manual testing on physical devices.")

    # ── 4.2 Detailed Implementation ──
    add_heading(doc, "4.2 Detailed Implementation")
    add_body(doc, "This section describes the major mobile subsystems implemented by the Software Engineering team.")

    add_heading(doc, "4.2.1 Authentication and Onboarding", level=2)
    add_body(doc,
        "The login screen (Figure 1) offers Google OAuth and Apple Sign-In buttons. Google authentication "
        "is fully functional: OAuthSignInService obtains an ID token, AuthRepository exchanges it with "
        "the backend /auth/google endpoint, and the JWT is stored locally. Apple Sign-In UI is implemented "
        "but production deployment is deferred because the project does not currently hold an Apple "
        "Developer Program membership. After login, AppStartupScreen routes new users to profile creation "
        "and returning users to mode selection.")
    add_figure(doc, *FIGURES[0])

    add_heading(doc, "4.2.2 Multi-Mode Profile System", level=2)
    add_body(doc,
        "VEXA supports three modes with distinct profile schemas. Social mode (Figures 4–5) captures "
        "personal attributes: age, height, weight, gender, education, smoking/alcohol habits, hobbies, "
        "bio, and an ice-breaker question. Ghost mode (Figures 8–9) stores only name, surname, and age "
        "for minimal identity exposure. Business mode (Figures 11–12) captures professional data: title, "
        "company/university, department, city, work status, professional tags, collaboration interests, "
        "and an elevator-pitch bio. Profiles are persisted locally via UserProfileStore and synchronised "
        "with the backend user endpoint.")
    add_figure(doc, *FIGURES[3])
    add_figure(doc, *FIGURES[4])
    add_figure(doc, *FIGURES[7])
    add_figure(doc, *FIGURES[8])
    add_figure(doc, *FIGURES[10])
    add_figure(doc, *FIGURES[11])

    add_heading(doc, "4.2.3 Discovery Filters", level=2)
    add_body(doc,
        "Users can configure discovery preferences before entering Social mode (Figures 2–3). Filters "
        "include age range (dual-thumb slider), gender preference, height range, weight range, education "
        "level, smoking, and alcohol preferences. DiscoveryFiltersStore persists selections locally and "
        "DiscoveryFiltersProvider sends them to the backend GET /matches/candidates endpoint. Empty "
        "filters are ignored server-side, allowing flexible matching criteria.")
    add_figure(doc, *FIGURES[1])
    add_figure(doc, *FIGURES[2])

    add_heading(doc, "4.2.4 Matching, Quiz, and History", level=2)
    add_body(doc,
        "The matching subsystem implements mode-specific post-match flows. In Social mode, when "
        "LiveMatchWatcher detects a pending match, the user is navigated to LiveQuizScreen for a "
        "5-question compatibility quiz. A score of ≥80% marks the match as completed and unlocks the "
        "matched person card in Social history (Figures 6–7). Scores below 80% set status to quiz_failed "
        "and apply a 2-hour cooldown (MatchCooldownStore). In Business/Networking mode, matches bypass "
        "the quiz entirely: NetworkMatchScreen presents the person card directly, and the entry appears "
        "in network history only. Cross-mode isolation is enforced: Social matches never appear in "
        "network history and vice versa.")
    add_figure(doc, *FIGURES[5])
    add_figure(doc, *FIGURES[6])

    add_heading(doc, "4.2.5 BLE Device Integration and Binding", level=2)
    add_body(doc,
        "Each user binds exactly one LilyGO device via DeviceConnectionScreen. BoundLilygoStore "
        "persists the BLE device name (e.g., VEXA-80DC18D9B4DC) per user ID in SharedPreferences. "
        "BleAvatarTransferService uses pickBoundVexaDevice to ensure avatar bitmaps, clock displays, "
        "DEF3 commands, and 0x06 match signals are transmitted only to the bound device. "
        "BleDeviceSettingsScreen (Figure 13) allows changing or removing the pairing and configuring "
        "vibration intensity, brightness, and screen timeout.")
    add_figure(doc, *FIGURES[12])

    add_heading(doc, "4.2.6 VEXA Finder and Proximity Scanning", level=2)
    add_body(doc,
        "VexaFinderService (Figure 19) performs periodic BLE scans every 20 seconds when proximity "
        "scanning is enabled. Upon detecting a compatible VEXA device, the LilyGO vibrates, displays "
        "'QUIZ TIME' via firmware, and the phone opens a match invitation. CompassRssiTracker "
        "combines BLE RSSI values with the device compass to provide hot/cold directional feedback "
        "on the Match Compass screen.")
    add_figure(doc, *FIGURES[18])

    add_heading(doc, "4.2.7 Settings and Preferences", level=2)
    add_body(doc,
        "A comprehensive settings module covers notifications (Figure 14), privacy/security (Figure 15), "
        "accessibility (Figure 16), account management (Figure 17), block/hide list (Figure 20), "
        "system permissions (Figure 21), and about screen (Figure 18). KVKK consent is recorded with "
        "timestamp (Figure 15). Dark mode, text scaling, and bold text are applied application-wide "
        "via ThemeModeProvider and AccessibilityPreferences.")
    add_figure(doc, *FIGURES[13])
    add_figure(doc, *FIGURES[14])
    add_figure(doc, *FIGURES[15])
    add_figure(doc, *FIGURES[16])
    add_figure(doc, *FIGURES[17])
    add_figure(doc, *FIGURES[19])
    add_figure(doc, *FIGURES[20])

    # ── 4.3 Department-Specific Contributions ──
    add_heading(doc, "4.3 Department-Specific Contributions (Software Engineering — Selçuk Büyükpoyraz)")
    add_body(doc, "Selçuk Büyükpoyraz was responsible for the entire mobile frontend of the VEXA platform. Specific contributions include:")
    add_bullet(doc, "Architecture and project scaffolding — Flutter project structure, routing, theme system, and API client layer.")
    add_bullet(doc, "Authentication — Google OAuth integration, login screen, session management, and Apple Sign-In UI (production deferred).")
    add_bullet(doc, "Multi-mode UI — Social, Ghost, and Business mode screens with swipe navigation and mode-specific styling.")
    add_bullet(doc, "Profile management — profile creation, editing, and display for all three modes with DiceBear avatar integration.")
    add_bullet(doc, "Discovery filters — client-side filter UI with dual-thumb sliders, chip selectors, and server-side filter submission.")
    add_bullet(doc, "Matching flows — LiveMatchWatcher, match invitation screens, mode-specific routing (quiz vs. direct card).")
    add_bullet(doc, "Live quiz system — 5-question quiz UI, scoring logic, cooldown enforcement, and quiz catalog.")
    add_bullet(doc, "Match history — mode-isolated history screens, matched person card display with compatibility and quiz scores.")
    add_bullet(doc, "BLE integration — avatar transfer protocol, device connection/binding UI, device settings, and VEXA Finder proximity scanner.")
    add_bullet(doc, "Compass/RSSI tracker — real-time direction finding using BLE signal strength and device compass.")
    add_bullet(doc, "Settings module — notifications, privacy, accessibility, account, KVKK consent, block list, and system permissions screens.")
    add_bullet(doc, "iOS configuration — Info.plist permissions (Bluetooth, location, motion), build and deployment to physical iPhones.")

    # ── 4.4 Integration and System Assembly ──
    add_heading(doc, "4.4 Integration and System Assembly")
    add_body(doc,
        "The mobile client integrates with three external systems: the Node.js REST backend, Supabase "
        "PostgreSQL database (via backend), and LilyGO wearable firmware over BLE.")
    add_body(doc, "Integration points:")
    add_bullet(doc, "Backend API — all authenticated endpoints (/auth, /users, /matches, /quiz) consumed via ApiClient with JWT bearer tokens.")
    add_bullet(doc, "Match lifecycle — backend creates match records; mobile polls via LiveMatchWatcher; quiz results POSTed to /matches/:id/quiz; history fetched via GET /matches/history?mode=social|networking.")
    add_bullet(doc, "Discovery filters — mobile sends filter JSON to backend; backend applies SQL-level filtering on candidate queries.")
    add_bullet(doc, "BLE protocol — custom GATT service (VexaBleConfig) with characteristics for avatar bitmap transfer (chunked writes), clock sync, match signal (0x05/0x06), and device settings (DEF3).")
    add_bullet(doc, "Per-user device binding — BoundLilygoStore prevents cross-user avatar misrouting when multiple LilyGO devices are in proximity.")
    add_bullet(doc, "Firmware coordination — match signal flow (LilyGO vibrate → 'QUIZ TIME' display → phone quiz invitation) tested with three physical devices.")
    add_body(doc,
        "End-to-end assembly was validated with two iPhones and three LilyGO devices. Each team member "
        "binds their own device, creates profiles in different modes, and triggers matches through "
        "both manual candidate selection and proximity scanning.")

    # ── 4.5 Challenges and Solutions ──
    add_heading(doc, "4.5 Challenges and Solutions")
    add_body(doc, "Several significant challenges were encountered during mobile development:")
    add_body(doc,
        "Challenge 1: Cross-device avatar misrouting. When three LilyGO devices with unique BLE names "
        "were deployed, avatar bitmaps were sent to the nearest device rather than the user's own device. "
        "Solution: Implemented BoundLilygoStore with per-user BLE name persistence. BleAvatarTransferService "
        "now calls pickBoundVexaDevice exclusively for avatar, clock, and match signal transfers.")
    add_body(doc,
        "Challenge 2: iOS build failure due to malformed Info.plist Bluetooth key. The NSBluetoothAlwaysUsageDescription "
        "key was corrupted, causing Xcode compilation errors. Solution: Corrected the Info.plist entry and "
        "added NSLocationWhenInUseUsageDescription and NSMotionUsageDescription for BLE scanning and compass access.")
    add_body(doc,
        "Challenge 3: Mode-crossing in match history. Social matches were appearing in network history "
        "and vice versa. Solution: Backend history endpoint now accepts a mode query parameter; frontend "
        "HistoryScreen passes modeContext from mode selection; LiveMatchWatcher routes to mode-specific screens.")
    add_body(doc,
        "Challenge 4: Apple Sign-In production readiness. Apple requires a paid Developer Program membership "
        "for Sign in with Apple on physical devices. Solution: UI implemented and visible on login screen; "
        "production deployment deferred. Google OAuth serves as the primary authentication method for MVP demo.")
    add_body(doc,
        "Challenge 5: BLE proximity in multi-device environments. With three VEXA devices broadcasting "
        "simultaneously, the scanner could pick up any device. Solution: Device binding ensures only the "
        "user's paired device receives commands; proximity scanner uses device name filtering for match detection.")

    # ── 5 Testing and Validation ──
    add_heading(doc, "5 Testing and Validation")
    add_body(doc,
        "Testing was conducted manually on physical iOS devices (iPhone) with the backend deployed on "
        "Render and three LilyGO wearable devices. No automated test suite was implemented for the MVP "
        "phase; validation focused on end-to-end user flows.")
    add_body(doc, "Test scenarios and results:")
    add_bullet(doc, "Authentication — Google login succeeds; JWT stored and used for subsequent API calls; logout clears session. PASS")
    add_bullet(doc, "Profile creation — Social, Ghost, and Business profiles created and persisted; avatar generated via DiceBear. PASS")
    add_bullet(doc, "Mode switching — Swipe navigation between Social, Ghost, and Business modes; mode-specific UI and profile gates displayed correctly. PASS")
    add_bullet(doc, "Discovery filters — Age, gender, height, weight, education, smoking, and alcohol filters applied; candidates returned match criteria. PASS")
    add_bullet(doc, "Social match + quiz — Match detected → quiz presented → ≥80% pass → person card unlocked in social history. PASS")
    add_bullet(doc, "Network match (no quiz) — Business mode match → person card shown directly → entry in network history only. PASS")
    add_bullet(doc, "History isolation — Social matches absent from network history and vice versa. PASS")
    add_bullet(doc, "Quiz cooldown — Failed quiz (<80%) triggers 2-hour cooldown before re-match. PASS")
    add_bullet(doc, "Device binding — Each user selects and binds own LilyGO device; avatar sent only to bound device. PASS")
    add_bullet(doc, "Device settings — Vibration, brightness, and screen timeout changes transmitted via BLE. PASS")
    add_bullet(doc, "VEXA Finder — Proximity scan detects nearby VEXA devices; demo alert flow functional. PASS")
    add_bullet(doc, "Settings — Dark mode, accessibility, notifications, privacy toggles, KVKK consent recorded. PASS")
    add_bullet(doc, "Apple Sign-In — UI renders correctly; production sign-in not tested (no Developer Program). DEFERRED")
    add_body(doc,
        "Known limitations: push notifications are configured in UI but not connected to APNs; "
        "blocked-user list is local-only (server sync planned); KVKK full legal text integration pending; "
        "TestFlight distribution not yet configured.")

    # ── 6.1 Final Results ──
    add_heading(doc, "6.1 Final Results")
    add_body(doc,
        "The VEXA mobile application delivers a functional MVP demonstrating the core wearable social "
        "and networking experience. All three operational modes (Social, Ghost, Business) are implemented "
        "with distinct profiles, discovery rules, and post-match flows. The application successfully "
        "communicates with the deployed backend for authentication, profile management, match creation, "
        "quiz submission, and mode-filtered history retrieval.")
    add_body(doc,
        "Hardware integration is operational: users bind individual LilyGO devices, transfer custom "
        "avatars, configure device settings, and receive match signals via BLE. The VEXA Finder "
        "proximity scanner detects nearby devices and triggers the match workflow. The Match Compass "
        "feature provides RSSI- and compass-based directional guidance.")
    add_body(doc,
        "The settings module provides a polished user experience covering notifications, privacy, "
        "accessibility, account management, and legal compliance (KVKK). The application version "
        "1.0.0+1 is installable on physical iPhones via Xcode direct deployment.")
    add_body(doc,
        "For MVP demo purposes, the system is approximately 100% feature-complete relative to the "
        "defined scope. Store-readiness (TestFlight, APNs push notifications, full KVKK integration, "
        "Apple Sign-In production) is estimated at 55–60% and represents post-MVP work.")
    add_figure(doc, *FIGURES[17])

    # ── 7.2 Individual Contributions ──
    add_heading(doc, "7.2 Individual Contributions")
    add_body(doc,
        "Selçuk Büyükpoyraz (Software Engineering) — Designed and implemented the entire Flutter mobile "
        "application including architecture, authentication, multi-mode UI, profile management, discovery "
        "filters, matching and quiz flows, match history, BLE device integration with per-user binding, "
        "VEXA Finder proximity scanning, Match Compass RSSI tracking, settings module, iOS build "
        "configuration, and physical device testing. Coordinated with the backend team (Can) on API "
        "contracts for match history filtering, quiz status updates, and discovery filter endpoints. "
        "Coordinated with the firmware team on BLE protocol characteristics and match signal flow.")
    add_body(doc,
        "Can (Software Engineering — Backend/Firmware) — Developed the Node.js REST API, Supabase "
        "database schema and migrations, match/quiz/history backend logic, and LilyGO firmware with "
        "unique BLE device names and match signal display. (Detailed in Can's report sections.)")

    # ── Appendix B ──
    doc.add_page_break()
    add_heading(doc, "Appendix B — User Manual / Installation Guide")
    add_body(doc,
        "This appendix provides step-by-step instructions for installing and using the VEXA mobile application.")

    add_heading(doc, "B.1 Installation (Developer / Test)", level=2)
    add_bullet(doc, "Prerequisites: macOS with Xcode 15+, Flutter SDK 3.x, CocoaPods, and a physical iOS device.")
    add_bullet(doc, "Clone the repository: git clone <vexa-repo-url> && cd frontend")
    add_bullet(doc, "Install dependencies: flutter pub get && cd ios && pod install && cd ..")
    add_bullet(doc, "Configure Google OAuth: set GOOGLE_CLIENT_ID in lib/core/config/google_oauth_config.dart.")
    add_bullet(doc, "Connect iPhone via USB; trust the developer certificate on the device.")
    add_bullet(doc, "Build and run: flutter run --release (or via Xcode Run button).")
    add_bullet(doc, "Backend URL is configured in lib/core/config/app_config.dart (production: https://vexa-backend-umg2.onrender.com/api).")

    add_heading(doc, "B.2 First-Time Setup", level=2)
    add_bullet(doc, "Launch the app and tap 'Continue with Google' on the welcome screen (Figure 1).")
    add_bullet(doc, "Complete your profile for the desired mode (Social, Ghost, or Business).")
    add_bullet(doc, "Select an avatar or customise via the DiceBear avatar picker.")
    add_bullet(doc, "Grant Bluetooth and notification permissions when prompted (Figure 21).")
    add_bullet(doc, "Navigate to Settings → Device Connection and select your LilyGO device from the BLE scan list (Figure 13).")

    add_heading(doc, "B.3 Using Social Mode", level=2)
    add_bullet(doc, "Swipe to Social mode on the home screen (Figure 2).")
    add_bullet(doc, "Configure discovery filters: age, gender, height, weight, education, smoking, alcohol (Figures 2–3).")
    add_bullet(doc, "When a match is detected, complete the 5-question quiz (≥80% required).")
    add_bullet(doc, "View matched person cards in History → Social (Figures 6–7).")

    add_heading(doc, "B.4 Using Business (Networking) Mode", level=2)
    add_bullet(doc, "Swipe to Business mode (Figure 10).")
    add_bullet(doc, "Ensure your network profile is complete (Figures 11–12).")
    add_bullet(doc, "Matches appear directly in History without a quiz requirement.")

    add_heading(doc, "B.5 Using Ghost Mode", level=2)
    add_bullet(doc, "Swipe to Ghost mode (Figure 8). Device enters low-energy standby; discovery is disabled.")
    add_bullet(doc, "Only minimal profile fields (name, surname, age) are visible (Figure 9).")

    add_heading(doc, "B.6 Device Management", level=2)
    add_bullet(doc, "Settings → Device Settings: view bound device, change pairing, adjust vibration/brightness/timeout (Figure 13).")
    add_bullet(doc, "Avatar changes are automatically transferred to the bound LilyGO device.")
    add_bullet(doc, "VEXA Finder (Figure 19): enable proximity scanning for automatic nearby-device match detection.")

    add_heading(doc, "B.7 Settings Reference", level=2)
    add_bullet(doc, "Notifications (Figure 14): toggle push, in-app, and match alerts.")
    add_bullet(doc, "Privacy (Figure 15): control discovery visibility, email display, and view KVKK consent.")
    add_bullet(doc, "Accessibility (Figure 16): adjust text size and enable bold text.")
    add_bullet(doc, "Account (Figure 17): dark mode, delete account, logout.")
    add_bullet(doc, "Block/Hide (Figure 20): locally exclude users from discovery.")

    add_heading(doc, "B.8 Screenshot Index", level=2)
    add_body(doc, "All application screenshots referenced in this report:")
    for _, caption in FIGURES:
        add_bullet(doc, caption)

    doc.save(str(OUTPUT))
    print(f"Saved: {OUTPUT}")
    print(f"Size: {OUTPUT.stat().st_size / 1024:.1f} KB")


if __name__ == "__main__":
    build_document()
