#!/usr/bin/env python3
"""Generate Section 3.1 Overall Approach DOCX for Selçuk and Can (VEXA Final Report)."""

from pathlib import Path
from docx import Document
from docx.shared import Pt, RGBColor, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.style import WD_STYLE_TYPE
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

OUTPUT = Path("/Users/selcukbuyukpoyraz/Desktop/VEXA_Section3_1_OverallApproach.docx")


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


def set_cell_shading(cell, color_hex):
    shading = OxmlElement("w:shd")
    shading.set(qn("w:fill"), color_hex)
    shading.set(qn("w:val"), "clear")
    cell._tc.get_or_add_tcPr().append(shading)


def add_table(doc, headers, rows):
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
    run = title.add_run(
        "VEXA — Section 3.1: Overall Approach\n"
        "(Methodology and Technical Approach)\n"
    )
    run.bold = True
    run.font.size = Pt(16)
    run.font.name = "Times New Roman"
    sub = doc.add_paragraph()
    sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    sr = sub.add_run(
        "Authors: Selçuk Büyükpoyraz (Mobile Frontend) & "
        "Yılmaz Can Çakmak (Backend / Firmware)\n"
        "Department: Software Engineering\n"
        "Date: June 2026"
    )
    sr.font.size = Pt(12)
    sr.font.name = "Times New Roman"
    doc.add_page_break()

    # ── Section 3 header ──
    add_heading(doc, "3. Methodology and Technical Approach")

    # ── 3.1 Overall Approach ──
    add_heading(doc, "3.1 Overall Approach", level=2)

    add_body(doc,
        "VEXA (Virtual Experience eXchange Application) is a wearable-assisted social and "
        "professional networking platform that connects users through proximity-based discovery, "
        "compatibility filtering, and interactive quiz gating. The system comprises three "
        "interconnected layers: a Flutter mobile client, a Node.js REST backend with PostgreSQL "
        "persistence, and LilyGO T-Display-S3 wearable firmware communicating over Bluetooth Low "
        "Energy (BLE). This section describes the overall engineering methodology adopted by "
        "the Software Engineering team to design, implement, and integrate these components "
        "into a demonstrable MVP.")

    add_heading(doc, "3.1.1 Problem Definition and Project Goals", level=3)
    add_body(doc,
        "The core problem addressed by VEXA is the friction in spontaneous social and professional "
        "encounters: users in shared physical spaces (campuses, conferences, co-working areas) "
        "lack a structured, consent-based mechanism to discover compatible individuals and initiate "
        "meaningful interaction. Traditional dating and networking applications rely on location "
        "services and swipe-based interfaces that do not leverage wearable hardware or real-time "
        "proximity signals.")
    add_body(doc, "The project goals, as defined in the original proposal, are:")
    add_bullet(doc, "Enable proximity-based user discovery via BLE wearable devices (LilyGO).")
    add_bullet(doc, "Support three operational modes: Social (dating/meeting), Ghost (low-energy standby), and Business (professional networking).")
    add_bullet(doc, "Apply multi-criteria discovery filters (age, gender, height, weight, education, lifestyle).")
    add_bullet(doc, "Gate Social matches behind a compatibility quiz (≥80% pass threshold) before revealing identity.")
    add_bullet(doc, "Allow Business matches to proceed directly without a quiz.")
    add_bullet(doc, "Display user avatars on wearable device screens via BLE transfer.")
    add_bullet(doc, "Provide match history with mode isolation and cooldown enforcement.")

    add_heading(doc, "3.1.2 Engineering Methodology", level=3)
    add_body(doc,
        "The team adopted an iterative, MVP-driven development methodology rather than a rigid "
        "waterfall model. This decision was motivated by three factors: (1) the novelty of "
        "integrating BLE wearables with a social matching backend, (2) the two-person team size "
        "requiring parallel workstreams, and (3) a fixed demo deadline (June 2026) that demanded "
        "early end-to-end validation over comprehensive documentation or automated testing.")
    add_body(doc, "The methodology follows these principles:")
    add_bullet(doc, "API-first integration — backend endpoints and API contracts (docs/api_contract.md) were defined before frontend consumption, enabling parallel development.")
    add_bullet(doc, "Vertical slice delivery — each sprint targeted a complete user journey (e.g., login → profile → match → quiz) rather than horizontal layer completion.")
    add_bullet(doc, "Physical device testing — all critical flows were validated on real iPhones and LilyGO hardware, not simulators alone.")
    add_bullet(doc, "Fail-fast iteration — integration issues (avatar misrouting, history mode crossing, Info.plist errors) were identified during E2E tests and resolved in subsequent sprints.")
    add_bullet(doc, "Documentation as contract — shared docs (BLE protocol, API contract, test rehberi) served as the single source of truth between frontend and backend developers.")

    add_heading(doc, "3.1.3 Team Structure and Division of Responsibility", level=3)
    add_body(doc,
        "The Software Engineering team consists of two developers working in parallel on "
        "complementary subsystems. Table 3-1 summarises the division of responsibility.")
    add_table(doc,
        ["Subsystem", "Lead Developer", "Primary Technologies", "Scope"],
        [
            ["Mobile client (Flutter/iOS)", "Selçuk Büyükpoyraz", "Flutter, Dart, Riverpod, flutter_blue_plus", "UI/UX, authentication, profiles, matching flows, quiz, history, BLE client, device binding, settings"],
            ["Backend API", "Yılmaz Can Çakmak", "Node.js, Express, Supabase PostgreSQL, Render", "REST API, JWT auth, OAuth (Google), database schema, match/quiz logic, discovery filters, migrations"],
            ["LilyGO firmware", "Yılmaz Can Çakmak", "ESP32, Arduino/PlatformIO, BLE GATT", "Avatar display, clock sync, match signals (0x05/0x06), device settings (DEF3), unique BLE names"],
            ["Shared integration", "Both", "Git, GitHub, docs/", "API contracts, BLE protocol spec, E2E testing, Render deployment"],
        ])

    add_heading(doc, "3.1.4 Selçuk Büyükpoyraz — Mobile Frontend Approach", level=3)
    add_body(doc,
        "The mobile development approach followed a feature-driven architecture within the Flutter "
        "framework. Rather than building all UI screens first and connecting them later, each feature "
        "module (auth, profile, matching, device, settings) was developed as a self-contained vertical "
        "slice with its own presentation, data, and domain layers.")
    add_body(doc, "Key methodological decisions:")
    add_bullet(doc, "Feature-first directory structure — code organised under features/auth, features/matching, features/device, etc., with shared utilities in core/.")
    add_bullet(doc, "Local-first with server sync — user preferences (theme, accessibility, blocked users) stored in SharedPreferences; profile and match data synchronised with backend via JWT-authenticated API calls.")
    add_bullet(doc, "Mode-context routing — every screen that depends on operational mode (Social, Ghost, Business) receives modeContext as a parameter, ensuring mode-specific behaviour without global state pollution.")
    add_bullet(doc, "BLE abstraction layer — BleAvatarTransferService encapsulates all GATT communication; BoundLilygoStore enforces per-user device binding to prevent cross-device data leakage in multi-device environments.")
    add_bullet(doc, "Progressive hardware integration — initial development used mock device flows; real BLE integration (avatar transfer, proximity scan, match signals) was added incrementally as firmware became available.")
    add_body(doc,
        "Development phases for the mobile client:")
    add_table(doc,
        ["Phase", "Period", "Deliverables"],
        [
            ["Phase 1 — Foundation", "Apr–May 2026", "Project scaffolding, theme system, navigation (GoRouter), login screen, mode selection UI"],
            ["Phase 2 — Backend integration", "May 2026", "Google OAuth, JWT session, profile CRUD via API, bio bridge for profile JSON"],
            ["Phase 3 — Matching & quiz", "May–Jun 2026", "LiveMatchWatcher, discovery filters, 5-question quiz, cooldown, mode-isolated history"],
            ["Phase 4 — BLE & hardware", "Jun 2026", "Avatar transfer, device binding, VEXA Finder, Match Compass (RSSI + compass), device settings"],
            ["Phase 5 — Polish & demo", "Jun 2026", "Settings module, KVKK consent, accessibility, regression testing on 2 iPhones + 3 LilyGO devices"],
        ])

    add_heading(doc, "3.1.5 Yılmaz Can Çakmak — Backend and Firmware Approach", level=3)
    add_body(doc,
        "The backend development followed an API-first, database-driven approach. Endpoints were "
        "designed according to REST conventions and documented in docs/api_contract.md before "
        "frontend integration. The database schema evolved from an initial in-memory store to "
        "a production Supabase PostgreSQL deployment with SQL migrations.")
    add_body(doc, "Key methodological decisions:")
    add_bullet(doc, "Layered backend architecture — Express routes → service layer (oauth_user.service, vexa_profile.service) → PostgreSQL queries via pg pool.")
    add_bullet(doc, "JWT-based stateless authentication — bcrypt password hashing for email/password; Google OAuth token verification via google-auth-library; JWT issued on successful auth.")
    add_bullet(doc, "Incremental database migration — schema changes applied via SQL migration files (e.g., 2026-06-11_quiz_cooldown_filters.sql) executed automatically on server startup through migrate.js.")
    add_bullet(doc, "Render cloud deployment — backend hosted on Render free tier with auto-deploy from dev branch; environment variables (JWT_SECRET, DATABASE_URL, GOOGLE_CLIENT_ID) managed via Render dashboard.")
    add_bullet(doc, "Separation of BLE concerns — backend does not handle BLE scanning; the architecture follows Device ↔ Flutter App ↔ Backend, with the mobile client as the BLE gateway.")
    add_body(doc,
        "For LilyGO firmware, Can adopted a protocol-driven development approach aligned with "
        "the BLE specification documented in docs/DEVICE_BLE_AVATAR_PROTOCOL.md:")
    add_bullet(doc, "GATT service with defined UUIDs for avatar write, clock sync (TIME_SYNC), and device settings (DEF3).")
    add_bullet(doc, "Chunked packet protocol — START (0x01) / DATA (0x02) / END (0x03) for avatar bitmap transfer; 7-byte clock format; match signal commands (0x05 vibration, 0x06 QUIZ TIME display).")
    add_bullet(doc, "Unique BLE device names — each of three physical devices programmed with distinct names (VEXA-80DC18D9B4DC, VEXA-88C318D9B4DC, VEXA-E8BD17D9B4DC) to support multi-device testing.")
    add_bullet(doc, "Firmware–mobile co-verification — each firmware feature (avatar display, clock, match signal) tested jointly with the Flutter BLE client before marking complete.")
    add_body(doc, "Development phases for backend and firmware:")
    add_table(doc,
        ["Phase", "Period", "Deliverables"],
        [
            ["Phase 1 — Backend foundation", "Apr–May 2026", "Express project setup, auth (register/login), Supabase connection, user/profile endpoints"],
            ["Phase 2 — OAuth & deployment", "May 2026", "Google OAuth (POST /auth/google), Render deployment, GOOGLE_CLIENT_ID configuration, health endpoint"],
            ["Phase 3 — Matching system", "May–Jun 2026", "Match candidates, match creation, quiz submission, history with mode filter, discovery filters (JSONB)"],
            ["Phase 4 — Database migration", "Jun 2026", "Quiz answers table, cooldown table, discovery_filters column, auto-migration on startup"],
            ["Phase 5 — Firmware integration", "Jun 2026", "Avatar display, clock sync, 0x05/0x06 match signals, device settings, 3-device firmware deployment"],
        ])

    add_heading(doc, "3.1.6 Cross-Team Integration Strategy", level=3)
    add_body(doc,
        "Given the two-person team and the dependency between mobile, backend, and firmware, "
        "a structured integration strategy was essential. The following practices were established:")
    add_bullet(doc, "Shared Git repository (vexa-project) with dev branch workflow — all changes merged to dev; Render auto-deploys backend on push.")
    add_bullet(doc, "API contract as integration boundary — docs/api_contract.md and docs/frontend_integration_guide.md define request/response formats; frontend ApiClient implements against these contracts.")
    add_bullet(doc, "BLE protocol document — docs/DEVICE_BLE_AVATAR_PROTOCOL.md defines packet formats, UUIDs, and command codes; both Flutter (vexa_ble_config.dart) and firmware implement the same specification.")
    add_bullet(doc, "Profile data bridge — during MVP, extended profile fields (Social/Business attributes) are serialised as JSON inside the bio column (VEXA_PROFILE_V1 prefix) until dedicated schema columns are added.")
    add_bullet(doc, "Weekly sync and shared test rehberi — docs/ARKADAS_BACKEND_VE_TEST_REHBERI.md and docs/CAN_KURULUM_VE_TEST.md provide step-by-step test procedures for both developers.")
    add_bullet(doc, "Joint E2E testing — critical flows (login → profile → proximity match → quiz → history → avatar on device) tested together on physical hardware before demo milestones.")
    add_body(doc,
        "Figure 3-1 presents the high-level integration flow adopted by the team.")

    # ASCII-style flow as formatted text block
    flow = doc.add_paragraph()
    flow.paragraph_format.space_after = Pt(6)
    flow.paragraph_format.line_spacing = 1.0
    run = flow.add_run(
        "┌─────────────┐     BLE GATT      ┌─────────────┐     REST/JSON     ┌─────────────┐\n"
        "│  LilyGO     │ ◄──────────────► │  Flutter    │ ◄──────────────► │  Node.js    │\n"
        "│  Firmware   │  Avatar, Clock,   │  Mobile App │  JWT Auth,       │  Backend    │\n"
        "│  (ESP32)    │  Match Signals    │  (iOS)      │  Match, Quiz,    │  (Render)   │\n"
        "│             │                   │             │  Profile API     │             │\n"
        "└─────────────┘                   └─────────────┘                   └──────┬──────┘\n"
        "       ▲                              ▲                                    │\n"
        "       │                              │                                    ▼\n"
        "  Can (Firmware)              Selçuk (Mobile)                    Supabase PostgreSQL\n"
        "                                                                         Can (Backend)"
    )
    run.font.name = "Courier New"
    run.font.size = Pt(9)
    cap = doc.add_paragraph("Figure 3-1. VEXA three-tier integration architecture and team responsibility mapping.", style="Report Caption")
    cap.alignment = WD_ALIGN_PARAGRAPH.CENTER

    add_heading(doc, "3.1.7 Design Methodology and Rationale", level=3)
    add_body(doc,
        "Several engineering design decisions distinguish the final approach from the initial "
        "proposal and reflect lessons learned during development:")
    add_table(doc,
        ["Design Decision", "Original Proposal", "Final Approach", "Rationale"],
        [
            ["Authentication", "Email/password registration", "Google OAuth (primary); Apple Sign-In UI deferred", "Faster onboarding; OAuth reduces password management; Apple requires paid Developer Program"],
            ["Profile storage", "Dedicated schema columns per field", "JSON in bio column (VEXA_PROFILE_V1 bridge) + local SharedPreferences", "Accelerated MVP; avoids frequent schema migrations for evolving profile fields"],
            ["BLE architecture", "Backend handles device scanning", "Mobile app as BLE gateway; backend stores pairing metadata only", "BLE scanning is OS-level; mobile has direct hardware access; backend remains stateless regarding radio"],
            ["Device binding", "Proximity-based nearest device", "Per-user explicit device binding (BoundLilygoStore)", "Prevents avatar/signal misrouting when multiple devices are in range"],
            ["Match flow", "Single match flow for all modes", "Mode-specific: Social (quiz gate) vs. Business (direct card)", "Different social contexts require different consent and information disclosure levels"],
            ["History", "Unified match history", "Mode-isolated history (GET /matches/history?mode=social|networking)", "Social and professional matches serve different user intents; cross-contamination avoided"],
            ["Testing", "Automated unit/integration tests", "Manual E2E testing on physical devices", "Two-person team, MVP timeline; automated tests planned post-MVP"],
        ])

    add_heading(doc, "3.1.8 Development Timeline and Milestones", level=3)
    add_body(doc,
        "The project followed a milestone-driven timeline aligned with academic reporting deadlines "
        "and the MVP demo target:")
    add_table(doc,
        ["Milestone", "Target Date", "Criteria", "Status"],
        [
            ["Progress Report", "Nov 2024", "~70–75% design and partial implementation documented", "Completed"],
            ["Backend MVP (API + DB)", "May 2026", "Auth, profile, match endpoints live on Render", "Completed"],
            ["Frontend–Backend integration", "May 2026", "Google login, profile sync, JWT flow working", "Completed"],
            ["BLE avatar transfer", "Jun 2026", "Avatar displayed on LilyGO from Flutter app", "Completed"],
            ["Quiz + cooldown + filters", "Jun 2026", "5-question quiz, 2h cooldown, server-side filters", "Completed"],
            ["Multi-device E2E demo", "Jun 2026", "2 iPhones + 3 LilyGO devices, full match flow", "Completed"],
            ["Final Report", "Jun 2026", "All sections documented with screenshots and test results", "In progress"],
        ])

    add_heading(doc, "3.1.9 Research and Requirements Validation", level=3)
    add_body(doc,
        "Although VEXA is primarily an engineering project rather than a research study, several "
        "research-informed methods were applied during requirements validation:")
    add_bullet(doc, "Competitive analysis — existing proximity-based and wearable social apps (e.g., AirDrop-style discovery, smartwatch companion apps) were reviewed to identify differentiation opportunities.")
    add_bullet(doc, "User scenario modelling — three persona-based scenarios (Social dater, Ghost mode user, Business networker) guided mode-specific profile schemas and match flows.")
    add_bullet(doc, "Technical feasibility study — BLE range (~15 m), GATT throughput for avatar transfer (~15–20 s for 128×128 RGB565), and Render cold-start latency (~30 s) were measured empirically during integration testing.")
    add_bullet(doc, "Iterative prototype evaluation — each development phase produced a testable prototype validated by the development team acting as end-user proxies; formal external UAT was deferred to post-MVP.")

    add_heading(doc, "3.1.10 Summary", level=3)
    add_body(doc,
        "The VEXA project adopted an iterative, MVP-driven, API-first development methodology "
        "executed by a two-person Software Engineering team. Selçuk Büyükpoyraz led mobile "
        "frontend development using a feature-driven Flutter architecture with progressive BLE "
        "integration. Yılmaz Can Çakmak led backend API development and LilyGO firmware "
        "programming using a protocol-driven, database-migration approach deployed on Render "
        "with Supabase PostgreSQL. Cross-team integration was governed by shared API contracts, "
        "BLE protocol specifications, and joint end-to-end testing on physical hardware. This "
        "methodology enabled the team to deliver a functional three-tier wearable social "
        "networking MVP within the project timeline, with identified post-MVP items (Apple "
        "Sign-In production, push notifications, TestFlight distribution, automated testing) "
        "documented for future work.")

    doc.save(str(OUTPUT))
    print(f"Saved: {OUTPUT}")
    print(f"Size: {OUTPUT.stat().st_size / 1024:.1f} KB")


if __name__ == "__main__":
    build()
