#!/usr/bin/env python3
"""Fill shared VEXA Capstone Checklist for Selçuk & Can (Software Engineering)."""

import shutil
from pathlib import Path
from docx import Document

SRC = Path("/Users/selcukbuyukpoyraz/Downloads/CapstoneChecklist.docx")
OUT = Path("/Users/selcukbuyukpoyraz/Desktop/VEXA_CapstoneChecklist_SoftwareEngineering.docx")

OVERVIEW = (
    "VEXA (Virtual Experience eXchange Application) is an interdisciplinary capstone project "
    "that integrates a LilyGO T-Display-S3 wearable device (ESP32, BLE, LCD, vibration motor), "
    "a Flutter mobile application (iOS), and a Node.js/Express backend with Supabase PostgreSQL "
    "hosted on Render. The system enables proximity-based social and professional networking in "
    "physical environments such as university campuses and conferences. Users select an operational "
    "mode (Social, Ghost, or Business), configure discovery filters, and interact through BLE-driven "
    "match workflows: Social matches require a five-question compatibility quiz (≥80% pass) before "
    "revealing identity; Business matches proceed directly. The MVP was validated on two iPhones and "
    "three LilyGO devices with per-user device binding, avatar transfer, match signals, and "
    "mode-isolated match history. This checklist is submitted jointly by the Software Engineering "
    "team members Selçuk Büyükpoyraz (mobile frontend) and Yılmaz Can Çakmak (backend API and firmware)."
)

ANSWERS = [
    # Part A — Overview (5)
    (
        "The VEXA integrated system must support user authentication (Google OAuth with JWT session), "
        "multi-mode profile management (Social, Ghost, Business), discovery filtering (age, gender, height, "
        "weight, education, smoking, alcohol), proximity-based match detection via BLE, a five-question "
        "compatibility quiz with ≥80% pass threshold for Social mode, direct person-card access for Business "
        "mode, mode-isolated match history, 2-hour post-quiz cooldown, avatar bitmap display on the LilyGO "
        "wearable, clock synchronisation, match alert signals (vibration and on-screen 'QUIZ TIME'), and "
        "configurable device settings (vibration intensity, brightness, screen timeout). Performance targets "
        "include: mobile app cold start under 5 seconds, authenticated API response under 2 seconds (warm "
        "backend), BLE avatar transfer under 30 seconds, proximity scan interval of 20 seconds, and match "
        "signal delivery to the wearable within 3 seconds."
    ),
    (
        "Dominant constraints include: (1) BLE range limited to approximately 10–15 metres with interference "
        "in crowded environments; (2) two-person Software Engineering team requiring parallel development "
        "with strict API and BLE protocol contracts; (3) MVP timeline (June 2026) prioritising demonstrable "
        "end-to-end flows over store distribution and automated testing; (4) iOS as primary mobile platform "
        "requiring Bluetooth, location, and notification permissions; (5) Render free-tier backend cold-start "
        "latency (~30–45 seconds after idle); (6) per-user device binding required when multiple LilyGO devices "
        "operate in proximity; (7) Turkish personal data law (KVKK) requiring explicit consent and data "
        "minimisation; (8) prototype hardware (development boards) rather than production enclosures, limiting "
        "battery life optimisation and manufacturability assessment."
    ),
    (
        "Primary users are young adults and professionals aged 18–35 in shared physical environments: university "
        "students (including international students adapting to new social circles), conference and event "
        "participants seeking professional networking, co-working space users looking for collaborators, and "
        "individuals with social anxiety who benefit from structured, consent-based interaction (quiz gating "
        "before identity reveal). Secondary users include demo evaluators, capstone advisors, and future "
        "early adopters in campus pilot deployments."
    ),
    (
        "The product is designed for indoor and outdoor campus/event environments at temperatures typical of "
        "Istanbul (approximately 5–35 °C), with users carrying a smartphone (iOS 17+) and wearing or carrying "
        "the LilyGO device. Operating assumptions include: Wi-Fi or cellular (4G/5G) connectivity for backend "
        "API access; BLE enabled on the phone; user consent for Bluetooth, location (BLE scan), and "
        "notification permissions; moderate user density (2–50 VEXA users in range during testing); continuous "
        "or periodic app usage during Social/Business mode; Ghost mode for low-energy standby without active "
        "discovery; and backend availability on Render with occasional cold-start delay after idle periods."
    ),
    (
        "The Software Engineering subsystem spans three layers: Flutter mobile client (Selçuk Büyükpoyraz), "
        "Node.js REST backend on Render with Supabase PostgreSQL (Yılmaz Can Çakmak), and LilyGO ESP32 firmware "
        "with custom BLE GATT protocol (Yılmaz Can Çakmak). Management Engineering team members (Tuana Çepikkurt, "
        "Kadir Karakuş) contributed market research, financial planning, and risk analysis documented separately "
        "in the final report. Integration is governed by shared documents: docs/api_contract.md, "
        "docs/DEVICE_BLE_AVATAR_PROTOCOL.md, and joint end-to-end testing on physical hardware."
    ),
    # Part B — Standards (5)
    (
        "As a low-power consumer wearable prototype (ESP32, 3.3 V logic, vibration motor, LCD), VEXA aligns "
        "with general electrical safety principles for battery-powered embedded devices. Relevant standards "
        "include IEC 62368-1 (audio/video and ICT equipment safety — applicable to consumer electronics "
        "with display and wireless modules) and ISO 9241 (ergonomics of human-system interaction — "
        "informing mobile UI accessibility features such as text scaling and bold text). The vibration motor "
        "operates at non-hazardous haptic levels for alert purposes only; no medical or therapeutic claims "
        "are made. Full CE/FCC certification was outside MVP scope."
    ),
    (
        "No legal metrology standards (e.g., weighing, measuring instruments) apply to VEXA. The device does "
        "not perform regulated measurements. BLE signal strength (RSSI) is used qualitatively for proximity "
        "and direction-finding feedback, not as a calibrated distance instrument."
    ),
    (
        "Performance was evaluated against project-defined criteria rather than external certification standards. "
        "Relevant industry references include Bluetooth SIG BLE specifications (GATT profile, advertising, "
        "connection parameters) which the firmware and mobile client implement; OAuth 2.0 (RFC 6749) for "
        "Google authentication; JWT (RFC 7519) for stateless session tokens; and REST/JSON API conventions. "
        "Mobile development follows Dart effective-style guidelines and Material Design 3 accessibility "
        "principles."
    ),
    (
        "Applicable regulations include: KVKK (Kişisel Verilerin Korunması Kanunu — Turkish Law No. 6698) "
        "for personal data processing (profile attributes, match history, email); GDPR principles referenced "
        "for international users; Google OAuth and Apple Sign-In platform policies for third-party "
        "authentication; Apple iOS App Store Review Guidelines (informing permission descriptions in "
        "Info.plist: NSBluetoothAlwaysUsageDescription, NSLocationWhenInUseUsageDescription, "
        "NSMotionUsageDescription); and general consumer product liability law regarding safe use of "
        "wearable electronics."
    ),
    (
        "Git version control and collaborative development follow standard software engineering practices. "
        "API contracts and BLE protocol specifications serve as internal interface standards between mobile, "
        "backend, and firmware subsystems. SQL migrations (e.g., 2026-06-11_quiz_cooldown_filters.sql) "
        "follow idempotent schema-change conventions executed automatically on backend startup."
    ),
    # Part C — Economic impacts (5)
    (
        "Prototype cost was minimised by using commercially available LilyGO T-Display-S3 development boards "
        "(~USD 15–20 per unit) instead of custom PCB fabrication, Render free-tier hosting for the backend, "
        "Supabase free-tier PostgreSQL, and Flutter/Xcode open-source tooling. Three firmware devices were "
        "programmed from a single codebase with unique BLE names. For mass production, costs could be reduced "
        "through: custom PCB with integrated battery management (~USD 8–12 at 1,000+ units), injection-moulded "
        "enclosure, negotiated component sourcing, paid Render/Supabase tiers for reliability, and elimination "
        "of per-device manual firmware flashing via OTA updates."
    ),
    (
        "Compared to smartphone-only social apps (Tinder, Bumble, LinkedIn), VEXA adds a one-time wearable "
        "hardware cost but reduces continuous screen engagement during physical interaction—the device acts as "
        "a passive social signal (avatar display, vibration alert) rather than requiring users to monitor an "
        "app. Compared to generic BLE beacons, VEXA provides integrated matching logic, quiz gating, and "
        "profile management, reducing the need for separate software subscriptions. The Ghost mode extends "
        "device utility beyond active matching, improving cost-per-use for the user."
    ),
    (
        "No specific tax incentives (renewable energy, carbon credits) apply directly to VEXA at the prototype "
        "stage. If the product were commercialised in Turkey, potential R&D tax deductions under Law No. 5746 "
        "(Araştırma ve Geliştirme Faaliyetlerinin Desteklenmesi) could apply to continued software and "
        "hardware development. Energy-efficient Ghost mode design may support future eco-labelling claims "
        "but was not evaluated for tax benefit eligibility during MVP."
    ),
    (
        "Supply chain vulnerability exists for ESP32 modules and LCD panels due to global semiconductor "
        "demand fluctuations. The design uses widely available ESP32-S3 and standard SPI LCD components to "
        "mitigate scarcity risk. Cloud dependency on Render (US-hosted) introduces currency and service "
        "availability considerations; migration to a regional provider (e.g., AWS eu-central-1) would reduce "
        "latency and geopolitical risk for Turkish users. Open-source Flutter and Node.js reduce vendor "
        "lock-in compared to proprietary mobile/backend platforms."
    ),
    (
        "The two-person Software Engineering team operated without dedicated hardware budget beyond three "
        "LilyGO boards, relying on personal iPhones for mobile testing. Apple Developer Program enrollment "
        "(USD 99/year) was deferred, limiting TestFlight distribution but avoiding immediate cost. Future "
        "commercialisation would require budget allocation for certification, manufacturing tooling, and "
        "marketing—estimated in the Management Engineering financial plan section of the final report."
    ),
    # Part D — Environmental impact (5)
    (
        "Direct greenhouse gas emissions from VEXA prototype use are minimal: low-power ESP32 (~100–240 mA "
        "during active BLE/screen), periodic rather than continuous BLE scanning (20-second intervals), and "
        "Ghost mode disabling discovery to reduce energy consumption. Cloud backend on Render contributes "
        "indirect emissions through data centre energy use; this was not quantified for MVP. Design decisions "
        "to reduce emissions include: Ghost mode standby, chunked BLE avatar transfer (avoiding re-transmission), "
        "and server-side filter application (reducing unnecessary match computations)."
    ),
    (
        "The wearable device consumes electrical energy from an integrated or USB-supplied battery; no water "
        "or wood resources are used. The mobile application minimises background BLE scanning when proximity "
        "mode is disabled. Backend database queries use indexed PostgreSQL columns to reduce compute energy. "
        "Screen brightness on the LilyGO is user-configurable (default 60%, with screen timeout options of "
        "10 s, 30 s, or continuous) to encourage efficient display use."
    ),
    (
        "The ESP32-S3 uses common silicon components without rare-earth-dependent display technologies. "
        "Standard SPI LCD and lithium-compatible power circuits were chosen over exotic materials. If supply "
        "chain disruption affects ESP32 availability, the modular architecture (separate mobile app, backend, "
        "firmware) allows firmware porting to alternative BLE-capable microcontrollers (e.g., nRF52) with "
        "protocol adaptation."
    ),
    (
        "VEXA encourages context-appropriate interaction (Social vs. Business mode separation), reducing "
        "wasteful mismatched approaches that lead to abandoned conversations. Ghost mode promotes carrying "
        "the device without active energy-intensive discovery, extending product lifespan beyond single-purpose "
        "use. Quiz-gated Social matching reduces low-quality connections, potentially decreasing repeated "
        "app/device usage cycles for unsuccessful matches."
    ),
    (
        "End-of-life disposal of prototype LilyGO boards was not formalised; development boards contain "
        "soldered components that should be recycled through e-waste programmes rather than landfill. A "
        "production version would require a take-back or recycling policy. Packaging was not applicable at "
        "the prototype stage."
    ),
    # Part E — Social impact (5)
    (
        "Positive impacts: VEXA facilitates structured, consent-based social and professional connections in "
        "physical spaces, potentially reducing social anxiety through quiz gating (identity revealed only after "
        "≥80% compatibility). The wearable avatar acts as a non-intrusive icebreaker. Business mode supports "
        "efficient professional networking at events. Negative impacts: proximity-based discovery could enable "
        "unwanted attention if block/hide features are insufficient (currently local-only). Misuse scenarios "
        "include fake profiles and spam matching. Mitigations: quiz cooldown (2 hours after failure), "
        "discovery filters, block/hide list, KVKK consent recording, mode isolation (Social vs. Business), "
        "and per-user device binding preventing signal misrouting."
    ),
    (
        "VEXA addresses social needs for: (1) structured meeting in university and international student "
        "communities; (2) intent-aware professional networking at conferences; (3) low-pressure interaction "
        "for socially anxious individuals via quiz-before-reveal; (4) passive social signalling through wearable "
        "avatar display without continuous phone use; (5) privacy control through Ghost mode (minimal identity "
        "exposure, discovery disabled)."
    ),
    (
        "Beneficiaries include university students, international students, conference attendees, co-working "
        "professionals, and individuals seeking both social and professional connections in shared physical "
        "environments. The capstone team and advisors benefit from demonstrated interdisciplinary engineering "
        "competency. Future campus pilot participants would benefit from improved on-site networking efficiency."
    ),
    (
        "Mass production of VEXA could create jobs in hardware manufacturing (assembly, QA), firmware "
        "development, mobile/backend software engineering, customer support, and marketing. It is unlikely to "
        "destroy existing jobs; it competes indirectly with pure app-based dating/networking platforms by "
        "adding a hardware layer but does not automate human social interaction. Management Engineering "
        "analysis in the final report estimates a small initial team (5–10 employees) for a startup launch scenario."
    ),
    (
        "Cultural sensitivity was considered: mode separation prevents inappropriate social approaches in "
        "professional settings. Discovery filters (gender, age, lifestyle) allow users to define comfort "
        "boundaries. Turkish-language UI supports local users; academic report and API documentation are in "
        "English following faculty requirements."
    ),
    # Part F — Health and safety (5)
    (
        "VEXA complies with general principles of safe consumer electronics use. iOS permission descriptions "
        "(Info.plist) inform users about Bluetooth, location, and notification access. KVKK consent is "
        "recorded with timestamp in the mobile app. No medical device standards (ISO 13485, IEC 60601) apply. "
        "BLE transmission power is within standard consumer limits (Class 2, ~2.5 mW). The vibration motor "
        "provides brief haptic alerts at non-harmful intensity."
    ),
    (
        "During prototype development, the team followed safe laboratory practices: soldering and firmware "
        "flashing in well-ventilated areas; USB-powered device testing with surge-protected connections; "
        "avoiding lithium battery puncture or short-circuit during hardware handling; taking regular breaks "
        "during extended coding sessions; and testing BLE devices without obstructing walkways in shared "
        "workspaces. No hazardous chemicals or high-voltage equipment were used."
    ),
    (
        "Design safety decisions include: (1) vibration alerts limited to brief match notifications, not "
        "continuous operation; (2) screen brightness capped at user-configurable maximum (default 60%); "
        "(3) no physical buttons on the wearable reducing mechanical failure risk; (4) per-user device binding "
        "preventing unintended signal delivery to wrong users; (5) quiz gating preventing immediate full identity "
        "disclosure; (6) logout and account deletion options in mobile settings; (7) Ghost mode for users who "
        "wish to disable active discovery."
    ),
    (
        "Potential misuse impacts: (1) stalking or harassment via repeated proximity matching — mitigated by "
        "cooldown, block list, and future server-side reporting; (2) BLE tracking of users without consent — "
        "mitigated by requiring authenticated match flow (not open beacon tracking); (3) eye strain from "
        "wearable screen — mitigated by screen timeout settings; (4) distraction from vibration alerts in "
        "sensitive environments (classrooms, meetings) — mitigated by user-configurable vibration off/light/strong; "
        "(5) data breach exposing profile/match history — mitigated by JWT authentication, HTTPS API, and "
        "Supabase access controls."
    ),
    (
        "The device is not waterproof; exposure to rain or liquid could cause electrical short-circuit. Users "
        "are advised to treat the prototype as a development board, not a rugged consumer product. Production "
        "version would require IP rating assessment and enclosure sealing."
    ),
    # Part G — Legal (5)
    (
        "Applicable laws and regulations: KVKK (Law No. 6698) for processing personal data of Turkish users; "
        "GDPR (EU Regulation 2016/679) referenced for international users; Turkish Consumer Protection Law "
        "(Tüketicinin Korunması Hakkında Kanun) for future commercial sales; OAuth 2.0 platform terms (Google); "
        "Apple App Store and Sign in with Apple guidelines; Bluetooth SIG trademark usage guidelines for BLE; "
        "and general intellectual property law (Fikri Mülkiyet Kanunu) for software and hardware design."
    ),
    (
        "Potential mass-production defects include: firmware crash causing frozen display (mitigated by watchdog "
        "timer in production firmware); BLE pairing failure (mitigated by factory binding test); battery "
        "swelling from defective cells (mitigated by certified battery supplier and BMS); incorrect vibration "
        "motor installation (mitigated by QA checklist); and data synchronisation errors (mitigated by "
        "automated integration tests before release). Manufacturer liability would require product warranty "
        "terms and defect reporting channel—planned for post-MVP commercialisation."
    ),
    (
        "No patent or license violations were identified during MVP development. Open-source dependencies "
        "(Flutter/BSD, Node.js/MIT, Express/MIT, flutter_blue_plus/BSD) were used in compliance with their "
        "licenses. DiceBear avatar API terms were reviewed for MVP usage. Google OAuth and Supabase services "
        "operate under their respective terms of service. Custom BLE UUIDs use a project-specific namespace "
        "avoiding Bluetooth SIG reserved ranges. Mass production would require formal IP search and freedom-to-operate "
        "analysis before market entry."
    ),
    (
        "Privacy laws (KVKK, GDPR) require: lawful basis for processing (consent via KVKK form with timestamp "
        "07.06.2026 recorded in app); data minimisation (Ghost mode stores minimal fields; filters optional); "
        "purpose limitation (data used only for matching, not sold to third parties); storage limitation "
        "(account deletion option in settings); and security measures (JWT tokens, HTTPS, bcrypt password hashing, "
        "Supabase row-level access). Email display on profile is opt-in (default off). Discovery visibility toggle "
        "allows users to exclude themselves from candidate lists (local preference; server sync planned)."
    ),
    (
        "Generative AI tools (ChatGPT, Cursor AI, Gemini) were used for brainstorming, code assistance, grammar "
        "editing, and report drafting, as declared in the Student Declaration and AI Usage sections of the final "
        "report. All AI-generated content was verified and rewritten by team members who accept full authorship "
        "responsibility."
    ),
    # Part H — Others (1)
    (
        "The Software Engineering team demonstrated that a two-person sub-team can deliver a functional "
        "cyber-physical social networking MVP within a single academic semester by adopting API-first integration, "
        "protocol-driven BLE development, and iterative end-to-end testing on physical hardware. Key lessons "
        "for standards and sustainability: per-user device binding is essential for multi-device environments; "
        "KVKK compliance must be designed into the mobile app from the start rather than added post-hoc; Ghost "
        "mode provides a meaningful sustainability and privacy feature beyond the original two-mode proposal; "
        "and cloud free-tier hosting introduces latency constraints that must be disclosed to users. Post-MVP "
        "priorities include Apple Developer Program enrollment, APNs push notifications, automated testing, "
        "formal UAT, and production enclosure design with CE/FCC certification assessment."
    ),
]


def set_cell_text(cell, text):
    cell.text = text


def fill_checklist():
    shutil.copy(SRC, OUT)
    doc = Document(OUT)

    # Header table
    hdr = doc.tables[0]
    set_cell_text(hdr.rows[0].cells[0], "Student name: Selçuk Büyükpoyraz & Yılmaz Can Çakmak")
    set_cell_text(hdr.rows[0].cells[1], "Student id: Selçuk Büyükpoyraz — 2203270; Yılmaz Can Çakmak — 2101587")
    set_cell_text(hdr.rows[0].cells[2], "Course: 4992")
    set_cell_text(hdr.rows[1].cells[0], "Project Title: VEXA — Electronic Device and Application for Social Interaction")
    set_cell_text(hdr.rows[1].cells[1], "Project code: 1011247")
    set_cell_text(hdr.rows[1].cells[2], "Date: 12/06/2026")

    # Overview + 36 answer tables (tables 1–37)
    set_cell_text(doc.tables[1].rows[0].cells[0], OVERVIEW)
    for i, answer in enumerate(ANSWERS):
        set_cell_text(doc.tables[i + 2].rows[0].cells[0], answer)

    doc.save(OUT)
    print(f"Saved: {OUT}")


if __name__ == "__main__":
    fill_checklist()
