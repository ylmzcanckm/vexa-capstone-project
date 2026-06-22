#!/usr/bin/env python3
"""Generate Section 5 (5.1–5.3) Testing and Validation DOCX for Selçuk's VEXA report."""

from pathlib import Path
from docx import Document
from docx.shared import Inches, Pt, RGBColor, Cm
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.style import WD_STYLE_TYPE
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

OUTPUT = Path("/Users/selcukbuyukpoyraz/Desktop/Selcuk_VEXA_Section5_Testing.docx")
SCREENSHOTS = Path("/Users/selcukbuyukpoyraz/Desktop/app screenshots")

# Screenshots used as test evidence in 5.2
TEST_FIGURES = [
    ("IMG_1587.PNG", "Figure 5-1. Authentication screen — Google OAuth login flow verified on physical iPhone."),
    ("IMG_1592.PNG", "Figure 5-2. Social match history — quiz score and compatibility displayed after successful match."),
    ("IMG_1593.PNG", "Figure 5-3. Matched person card unlocked after ≥80% quiz pass (Social mode)."),
    ("IMG_1596.PNG", "Figure 5-4. Business mode active — network card ready, no quiz required."),
    ("IMG_1599.PNG", "Figure 5-5. Per-user LilyGO device binding confirmed (VEXA-80DC18D9B4DC, connection active)."),
    ("IMG_1605.PNG", "Figure 5-6. VEXA Finder proximity scan toggle and LilyGO pairing status."),
]


def setup_styles(doc):
    styles = doc.styles
    if "Report Heading 1" not in [s.name for s in styles]:
        h1 = styles.add_style("Report Heading 1", WD_STYLE_TYPE.PARAGRAPH)
        h1.font.name = "Times New Roman"
        h1.font.size = Pt(14)
        h1.font.bold = True
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
    run.add_picture(str(img_path), width=Inches(2.6))
    cap = doc.add_paragraph(caption, style="Report Caption")
    cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
    cap.paragraph_format.space_after = Pt(12)


def set_cell_shading(cell, color_hex):
    shading = OxmlElement("w:shd")
    shading.set(qn("w:fill"), color_hex)
    shading.set(qn("w:val"), "clear")
    cell._tc.get_or_add_tcPr().append(shading)


def add_test_table(doc, headers, rows):
    table = doc.add_table(rows=1 + len(rows), cols=len(headers))
    table.style = "Table Grid"
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    hdr = table.rows[0].cells
    for i, h in enumerate(headers):
        hdr[i].text = h
        set_cell_shading(hdr[i], "D9E2F3")
        for p in hdr[i].paragraphs:
            for run in p.runs:
                run.bold = True
                run.font.name = "Times New Roman"
                run.font.size = Pt(10)
    for ri, row in enumerate(rows):
        cells = table.rows[ri + 1].cells
        for ci, val in enumerate(row):
            cells[ci].text = val
            for p in cells[ci].paragraphs:
                for run in p.runs:
                    run.font.name = "Times New Roman"
                    run.font.size = Pt(10)
    doc.add_paragraph()
    return table


def build():
    doc = Document()
    setup_styles(doc)

    # Title
    title = doc.add_paragraph()
    title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = title.add_run("VEXA — Section 5: Testing and Validation\n(Software Engineering / Mobile Frontend)\n")
    run.bold = True
    run.font.size = Pt(16)
    run.font.name = "Times New Roman"
    sub = doc.add_paragraph()
    sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    sr = sub.add_run("Author: Selçuk Büyükpoyraz\nDepartment: Software Engineering\nDate: June 2026")
    sr.font.size = Pt(12)
    sr.font.name = "Times New Roman"
    doc.add_page_break()

    # ── Section 5 heading ──
    add_heading(doc, "5. Testing and Validation")
    add_body(doc,
        "This section documents the testing and validation activities performed on the VEXA mobile "
        "application (Flutter/iOS). Testing was conducted during the MVP phase (May–June 2026) using "
        "physical iPhones, three LilyGO wearable devices, and the production backend deployed on Render "
        "(https://vexa-backend-umg2.onrender.com/api). The scope covers the mobile client; backend and "
        "firmware testing is documented separately by the backend team.")

    # ── 5.1 Test Plan ──
    add_heading(doc, "5.1 Test Plan", level=2)
    add_body(doc,
        "Given the MVP timeline and team size, testing followed a pragmatic, risk-based strategy "
        "centred on manual end-to-end validation of critical user flows. Automated unit and widget "
        "tests were not implemented in the MVP phase; this is identified as post-MVP technical debt.")
    add_body(doc, "The testing strategy comprised four layers:")

    add_heading(doc, "5.1.1 Unit Testing", level=3)
    add_body(doc,
        "Unit testing of individual Dart functions (e.g., filter serialisation, quiz scoring logic, "
        "BLE protocol chunking) was planned but deferred to post-MVP. Logic correctness was verified "
        "indirectly through integration and system tests. Key candidates for future unit tests include "
        "DiscoveryFiltersStore serialisation, MatchCooldownStore expiry calculation, "
        "BoundLilygoStore read/write, and CompassRssiTracker warmth classification.")

    add_heading(doc, "5.1.2 Integration Testing", level=3)
    add_body(doc,
        "Integration testing focused on the interfaces between the mobile client and external systems:")
    add_bullet(doc, "Mobile ↔ REST API — JWT-authenticated calls to /auth/google, /users, /matches, /matches/history, /matches/:id/quiz.")
    add_bullet(doc, "Mobile ↔ Supabase (via backend) — profile persistence, match record creation, quiz status updates, mode-filtered history.")
    add_bullet(doc, "Mobile ↔ LilyGO firmware — GATT characteristic read/write for avatar transfer, device settings (DEF3), and match signals (0x05/0x06).")
    add_bullet(doc, "Mobile ↔ Google OAuth — ID token exchange and session token storage.")
    add_body(doc,
        "Integration tests were executed manually: two developer accounts on separate iPhones "
        "triggered cross-user match flows while observing backend responses via network logs and "
        "on-device UI state.")

    add_heading(doc, "5.1.3 System Testing", level=3)
    add_body(doc,
        "System testing validated complete user journeys on physical hardware. Test environment:")
    add_bullet(doc, "Devices: 2× iPhone (iOS 17+), 3× LilyGO T-Display-S3 with unique BLE names (VEXA-80DC18D9B4DC, VEXA-88C318D9B4DC, VEXA-E8BD17D9B4DC).")
    add_bullet(doc, "Backend: Render-hosted Node.js API with Supabase PostgreSQL.")
    add_bullet(doc, "Network: Wi-Fi / 5G cellular; backend cold-start latency accounted for (~30 s on first request).")
    add_body(doc, "System test scenarios covered:")
    add_bullet(doc, "Authentication and session lifecycle (login, token refresh, logout).")
    add_bullet(doc, "Profile creation and editing for Social, Ghost, and Business modes.")
    add_bullet(doc, "Mode switching via swipe navigation.")
    add_bullet(doc, "Discovery filter configuration and candidate retrieval.")
    add_bullet(doc, "Social match flow: detection → quiz → pass/fail → history → person card.")
    add_bullet(doc, "Business match flow: detection → direct person card → network history (no quiz).")
    add_bullet(doc, "History mode isolation (Social entries absent from network history and vice versa).")
    add_bullet(doc, "Quiz cooldown enforcement (2-hour block after <80% score).")
    add_bullet(doc, "LilyGO device binding, avatar transfer, and settings synchronisation.")
    add_bullet(doc, "VEXA Finder proximity scanning and match alert demo.")
    add_bullet(doc, "Settings module: notifications, privacy, accessibility, account, KVKK consent.")

    add_heading(doc, "5.1.4 User Acceptance Testing (UAT)", level=3)
    add_body(doc,
        "Formal UAT with external users was not conducted during the MVP phase due to the absence "
        "of TestFlight distribution and Apple Developer Program enrollment. Internal acceptance "
        "testing was performed by the two-person development team (Selçuk and Can) acting as "
        "end-user proxies. Acceptance criteria were derived from the project proposal success criteria:")
    add_bullet(doc, "Users can authenticate via Google and create mode-specific profiles.")
    add_bullet(doc, "Social matches require a quiz (≥80% pass) before revealing the person card.")
    add_bullet(doc, "Business matches reveal the person card immediately without a quiz.")
    add_bullet(doc, "Each user binds exactly one LilyGO device; avatar is sent only to the bound device.")
    add_bullet(doc, "Match history is filtered by mode and displays quiz score and compatibility.")
    add_bullet(doc, "The application runs stably on physical iPhones without crashes during demo flows.")

    add_heading(doc, "5.1.5 Test Schedule and Responsibilities", level=3)
    add_test_table(doc,
        ["Phase", "Period", "Activity", "Responsible"],
        [
            ["Integration", "May 2026", "API endpoint verification, JWT flow", "Selçuk (mobile), Can (backend)"],
            ["BLE integration", "May–Jun 2026", "Avatar transfer, device binding, match signals", "Selçuk (mobile), Can (firmware)"],
            ["System testing", "Jun 2026", "End-to-end flows on 2 iPhones + 3 LilyGO", "Selçuk, Can"],
            ["Regression", "Jun 2026", "Re-test after history/quiz/binding fixes", "Selçuk"],
            ["Demo rehearsal", "Jun 2026", "Full MVP demo walkthrough", "Selçuk, Can"],
        ])

    # ── 5.2 Test Results ──
    add_heading(doc, "5.2 Test Results", level=2)
    add_body(doc,
        "All system tests were executed manually. Results are summarised in Table 5-1. Screenshots "
        "documenting key outcomes are included as Figures 5-1 through 5-6.")

    add_heading(doc, "5.2.1 Authentication and Profile Tests", level=3)
    add_test_table(doc,
        ["Test ID", "Scenario", "Expected Result", "Actual Result", "Status"],
        [
            ["AUTH-01", "Google OAuth login", "JWT stored, user routed to mode selection", "Token persisted in AuthTokenStore; AppStartupScreen routes correctly", "PASS"],
            ["AUTH-02", "Apple Sign-In button tap", "UI renders; sign-in flow initiates", "UI visible; production sign-in not tested (no Developer Program)", "DEFERRED"],
            ["AUTH-03", "Logout", "Session cleared, login screen shown", "LocalSessionStore cleared; login screen displayed", "PASS"],
            ["PROF-01", "Create Social profile", "All fields saved and displayed", "Profile visible with avatar, age, hobbies, bio (Fig. 5-1 area)", "PASS"],
            ["PROF-02", "Create Ghost profile", "Minimal fields only (name, surname, age)", "Only three fields shown in Ghost profile view", "PASS"],
            ["PROF-03", "Create Business profile", "Professional fields saved", "Title, company, tags, bio displayed correctly", "PASS"],
            ["PROF-04", "Edit profile", "Changes persisted after save", "Edited fields reflected on re-open", "PASS"],
        ])

    add_heading(doc, "5.2.2 Mode and Discovery Tests", level=3)
    add_test_table(doc,
        ["Test ID", "Scenario", "Expected Result", "Actual Result", "Status"],
        [
            ["MODE-01", "Swipe Social → Ghost → Business", "Mode-specific UI and colour accent change", "Correct mode screen and styling for each mode", "PASS"],
            ["MODE-02", "Social discovery filters (age, gender)", "Filters applied to candidate query", "Filtered candidates returned matching criteria", "PASS"],
            ["MODE-03", "Extended filters (height, weight, education, smoking, alcohol)", "Empty filters ignored; set filters applied", "Server-side filtering confirmed via candidate list", "PASS"],
            ["MODE-04", "Reset filters", "All filters cleared to defaults", "Sliders and chips reset correctly", "PASS"],
        ])

    add_heading(doc, "5.2.3 Matching, Quiz, and History Tests", level=3)
    add_test_table(doc,
        ["Test ID", "Scenario", "Expected Result", "Actual Result", "Status"],
        [
            ["MATCH-01", "Social match detected", "LiveQuizScreen opens with 5 questions", "Quiz presented; LiveMatchWatcher routing correct", "PASS"],
            ["MATCH-02", "Quiz pass (≥80%)", "Match status = completed; person card in social history", "History shows quiz %100, score 95 (Fig. 5-2, 5-3)", "PASS"],
            ["MATCH-03", "Quiz fail (<80%)", "Match status = quiz_failed; 2h cooldown applied", "Re-match blocked for 2 hours via MatchCooldownStore", "PASS"],
            ["MATCH-04", "Business match detected", "NetworkMatchScreen opens directly (no quiz)", "Person card shown immediately (Fig. 5-4)", "PASS"],
            ["MATCH-05", "Social history isolation", "Social matches absent from network history", "GET /matches/history?mode=networking excludes social entries", "PASS"],
            ["MATCH-06", "Network history isolation", "Network matches absent from social history", "GET /matches/history?mode=social excludes network entries", "PASS"],
            ["MATCH-07", "Person card detail", "Compatibility %, quiz %, bio displayed", "All fields rendered on MatchedPersonCardScreen (Fig. 5-3)", "PASS"],
        ])
    add_figure(doc, *TEST_FIGURES[1])
    add_figure(doc, *TEST_FIGURES[2])

    add_heading(doc, "5.2.4 BLE and Device Integration Tests", level=3)
    add_test_table(doc,
        ["Test ID", "Scenario", "Expected Result", "Actual Result", "Status"],
        [
            ["BLE-01", "Scan and list VEXA devices", "All 3 devices visible with unique names", "VEXA-80DC18D9B4DC, VEXA-88C318D9B4DC, VEXA-E8BD17D9B4DC detected", "PASS"],
            ["BLE-02", "Bind device to user", "BLE name stored per user ID", "BoundLilygoStore persists binding; settings show device name (Fig. 5-5)", "PASS"],
            ["BLE-03", "Avatar transfer to bound device", "Avatar displayed on correct LilyGO only", "After binding fix: avatar sent only to user's device", "PASS"],
            ["BLE-04", "Change device pairing", "New device bound; old binding removed", "DeviceConnectionScreen updates binding correctly", "PASS"],
            ["BLE-05", "Device settings (vibration, brightness, timeout)", "Settings transmitted via BLE DEF3 command", "Vibration/brightness/timeout changes applied on device", "PASS"],
            ["BLE-06", "Match signal (0x06)", "LilyGO vibrates and shows 'QUIZ TIME'", "Firmware display and vibration confirmed on device", "PASS"],
            ["BLE-07", "VEXA Finder proximity scan", "Scan every 20 s; demo alert functional", "Toggle works; demo alert opens match invitation (Fig. 5-6)", "PASS"],
            ["BLE-08", "Match Compass (RSSI + compass)", "Hot/cold feedback based on signal direction", "Needle rotates; warmth indicator updates with proximity", "PASS"],
        ])
    add_figure(doc, *TEST_FIGURES[4])
    add_figure(doc, *TEST_FIGURES[5])

    add_heading(doc, "5.2.5 Settings and Preferences Tests", level=3)
    add_test_table(doc,
        ["Test ID", "Scenario", "Expected Result", "Actual Result", "Status"],
        [
            ["SET-01", "Dark mode toggle", "Theme applied application-wide", "VexaPalette dark theme active across all screens", "PASS"],
            ["SET-02", "Text size / bold text", "Accessibility preferences applied", "Font scaling and bold weight visible on all screens", "PASS"],
            ["SET-03", "Notification toggles", "Preferences saved locally", "Push/in-app/match toggles persist after app restart", "PASS"],
            ["SET-04", "KVKK consent", "Consent timestamp recorded", "Onay: 07.06.2026 displayed in privacy settings", "PASS"],
            ["SET-05", "Block/hide user (local)", "User excluded from local discovery list", "Local list functional; server sync not yet implemented", "PARTIAL"],
            ["SET-06", "Discovery visibility toggle", "Local preference saved", "Toggle persists; server sync planned", "PARTIAL"],
        ])

    add_heading(doc, "5.2.6 Failed and Deferred Tests", level=3)
    add_body(doc, "The following tests did not pass or were deferred:")
    add_test_table(doc,
        ["Test ID", "Scenario", "Issue", "Resolution / Status"],
        [
            ["FAIL-01", "Avatar sent to nearest LilyGO (pre-fix)", "Avatar bitmap routed to closest device, not user's device", "Fixed via BoundLilygoStore per-user binding (Jun 2026) — RESOLVED"],
            ["FAIL-02", "iOS build — Info.plist Bluetooth key", "Malformed NSBluetoothAlwaysUsageDescription caused compile error", "Key corrected; location and motion keys added — RESOLVED"],
            ["FAIL-03", "Social match in network history (pre-fix)", "History endpoint returned all matches regardless of mode", "Backend mode filter + frontend modeContext parameter added — RESOLVED"],
            ["DEF-01", "Apple Sign-In production", "Requires Apple Developer Program ($99/year)", "UI implemented; production deferred — DEFERRED"],
            ["DEF-02", "Push notifications (APNs)", "No APNs certificate configured", "UI toggles exist; delivery not tested — DEFERRED"],
            ["DEF-03", "Blocked users server sync", "Backend endpoint not yet implemented", "Local-only list functional — DEFERRED"],
        ])

    add_heading(doc, "5.2.7 Test Summary", level=3)
    add_test_table(doc,
        ["Category", "Total Tests", "Passed", "Partial", "Deferred", "Failed (resolved)"],
        [
            ["Authentication & Profile", "7", "6", "0", "1", "0"],
            ["Mode & Discovery", "4", "4", "0", "0", "0"],
            ["Matching, Quiz & History", "7", "7", "0", "0", "0"],
            ["BLE & Device", "8", "8", "0", "0", "0"],
            ["Settings", "6", "4", "2", "0", "0"],
            ["Total", "32", "29", "2", "1", "3 (all resolved)"],
        ])
    add_body(doc,
        "Overall pass rate for executable tests: 29/31 = 93.5% (excluding 1 deferred Apple Sign-In test). "
        "Two partial results relate to features with local-only implementation pending server synchronisation. "
        "Three previously failing tests were resolved during the regression cycle in June 2026.")

    add_figure(doc, *TEST_FIGURES[0])
    add_figure(doc, *TEST_FIGURES[3])

    # ── 5.3 Performance Evaluation ──
    add_heading(doc, "5.3 Performance Evaluation", level=2)
    add_body(doc,
        "Performance was evaluated against the success criteria defined in the VEXA project proposal. "
        "Quantitative measurements were collected during manual testing on physical devices. Where precise "
        "instrumentation was unavailable, qualitative observations are noted.")

    add_heading(doc, "5.3.1 Application Responsiveness", level=3)
    add_test_table(doc,
        ["Metric", "Target (Proposal)", "Measured", "Evaluation"],
        [
            ["App cold start (login → mode screen)", "< 5 s", "~2–3 s on iPhone (release build)", "MEETS"],
            ["Google OAuth round-trip", "< 10 s", "~3–5 s (including backend token exchange)", "MEETS"],
            ["Profile load from backend", "< 3 s", "~1–2 s (warm backend)", "MEETS"],
            ["Match history fetch", "< 3 s", "~1–2 s for ≤20 entries", "MEETS"],
            ["Mode switch (swipe animation)", "< 1 s", "~300 ms transition", "MEETS"],
            ["Quiz screen load", "< 2 s", "~500 ms", "MEETS"],
        ])

    add_heading(doc, "5.3.2 Backend and Network Performance", level=3)
    add_test_table(doc,
        ["Metric", "Target", "Measured", "Evaluation"],
        [
            ["Backend cold start (Render free tier)", "Functional within 60 s", "~30–45 s first request after idle", "ACCEPTABLE"],
            ["Authenticated API response (warm)", "< 2 s", "~200–800 ms average", "MEETS"],
            ["Match creation latency", "< 3 s", "~1 s", "MEETS"],
            ["Quiz submission latency", "< 2 s", "~500 ms", "MEETS"],
            ["History query with mode filter", "< 2 s", "~600 ms", "MEETS"],
        ])
    add_body(doc,
        "The Render free-tier cold start introduces noticeable delay on the first API call after "
        "periods of inactivity. This does not affect demo flows once the backend is warm but would "
        "require a paid tier or keep-alive strategy for production deployment.")

    add_heading(doc, "5.3.3 BLE and Hardware Performance", level=3)
    add_test_table(doc,
        ["Metric", "Target", "Measured", "Evaluation"],
        [
            ["BLE device scan duration", "< 10 s", "~4–6 s for 3 devices", "MEETS"],
            ["Avatar transfer (full bitmap)", "< 30 s", "~15–20 s (chunked GATT writes)", "MEETS"],
            ["Device settings sync (DEF3)", "< 5 s", "~2 s", "MEETS"],
            ["Proximity scan interval", "Every 20 s", "20 s (configurable in VexaFinderService)", "MEETS"],
            ["Match signal → LilyGO display", "< 3 s", "~1–2 s (vibrate + 'QUIZ TIME')", "MEETS"],
            ["Compass/RSSI update rate", "≥ 1 Hz", "~2 Hz while compass active", "MEETS"],
        ])

    add_heading(doc, "5.3.4 Resource Utilisation", level=3)
    add_test_table(doc,
        ["Metric", "Observation", "Evaluation"],
        [
            ["App install size (iOS release)", "~45 MB", "Acceptable for MVP"],
            ["Memory during active BLE scan", "No observable lag or crash", "Stable"],
            ["Battery impact (Ghost mode)", "Minimal — discovery disabled, device in standby", "MEETS low-energy goal"],
            ["Battery impact (Social + BLE scan)", "Moderate — periodic 20 s BLE scan", "Acceptable for demo; optimisation planned"],
            ["Crash rate during testing", "0 crashes in 10+ demo sessions", "MEETS stability criterion"],
        ])

    add_heading(doc, "5.3.5 Functional Completeness vs. Proposal Criteria", level=3)
    add_test_table(doc,
        ["Proposal Criterion", "Status", "Evidence"],
        [
            ["Multi-mode operation (Social, Ghost, Business)", "Achieved", "MODE-01 pass; Figures 5-2, 5-4"],
            ["Social quiz gate (≥80%) before person card", "Achieved", "MATCH-02, MATCH-03 pass; Figure 5-3"],
            ["Business direct match (no quiz)", "Achieved", "MATCH-04 pass; Figure 5-4"],
            ["Wearable avatar display via BLE", "Achieved", "BLE-03 pass; Figure 5-5"],
            ["Per-user device binding", "Achieved", "BLE-02 pass; binding fix verified"],
            ["Discovery filters (client + server)", "Achieved", "MODE-02, MODE-03 pass"],
            ["Match history with mode isolation", "Achieved", "MATCH-05, MATCH-06 pass; Figure 5-2"],
            ["Proximity-based match detection", "Achieved", "BLE-07 pass; Figure 5-6"],
            ["Google authentication", "Achieved", "AUTH-01 pass; Figure 5-1"],
            ["Apple authentication", "Partial — UI only", "AUTH-02 deferred"],
            ["Push notifications", "Partial — UI only", "DEF-02 deferred"],
            ["Store distribution (TestFlight)", "Not achieved", "Post-MVP"],
        ])

    add_body(doc,
        "Against the defined MVP scope, 9 of 12 proposal criteria are fully achieved, 2 are partially "
        "implemented (UI present, backend/production integration pending), and 1 (TestFlight distribution) "
        "is deferred to post-MVP. For demonstration purposes, the system meets all critical functional "
        "requirements. Store-readiness and production-grade authentication (Apple Sign-In, APNs) remain "
        "outstanding items estimated at 55–60% completion relative to a full App Store release.")

    doc.save(str(OUTPUT))
    print(f"Saved: {OUTPUT}")
    print(f"Size: {OUTPUT.stat().st_size / 1024:.1f} KB")


if __name__ == "__main__":
    build()
