# C4-MySkin — AGENTS.md

> Dokumen konteks kanonik untuk agent chat berikutnya. Wajib di-update setiap ada perubahan kode signifikan. Riwayat perubahan ada di bagian bawah.

## Overview

C4-MySkin adalah iOS app (SwiftUI, MVVM, feature-based) untuk tracking perjalanan skincare. Saat ini fok utama adalah **SkinJournal** — fitur jurnal & milestone tracking produk skincare berdasarkan desain Sketch di `C4-MySkin/Features/SkinJournal/Sketch/`.

## Stack & Konvensi

- **Bahasa**: Swift 5, SwiftUI, Observation macro (`@Observable`).
- **Architecture**: MVVM + feature-based folder structure.
- **Platform**: iOS 26.5+ (target SDK saat ini), iPhone Simulator/ device.
- **Design**: Apple HIG — semantic colors, SF Symbols, Dynamic Type ready, touch target 44pt+, safe area respect.
- **Storage**: `UserDefaults`-backed JSON via `SkinJournalStore` (Core/Storage).
- **Persistence rule**: semua state user (onboarding, journeys, entries) disimpan via `SkinJournalStore` supaya survive relaunch.

## Project Map

```text
C4-MySkin/
├── C4_MySkinApp.swift                 # Entry point -> SkinJournalRootView()
├── Core/
│   └── Storage/
│       └── SkinJournalStore.swift     # Persistensi journeys + onboarding + selected concerns
└── Features/
    ├── Home/                          # Template default, tidak aktif saat ini
    └── SkinJournal/
        ├── Components/                # Reusable UI: chips, buttons, timeline, cards
        ├── Models/                    # SkinConcern, SkincareProduct, SkincareJourney
        ├── ViewModels/                # One VM per screen/feature
        ├── Views/                     # SwiftUI screens
        └── Sketch/                    # Source desain dari Sketch (PNG)
```

## Fitur SkinJournal — Flow

1. **Main Page** (`SkinJournalMainView`)
   - Header: greeting "Hi, POLO!", bookmark icon, profile avatar.
   - Search prompt: "Check active products on you!".
   - Empty state: "No active product yet" card (jika belum ada journey).
   - Active state: Milestone card dengan icon produk, progress dashed line, "Goal: 4 weeks".
   - 2 circular action buttons: "Product validation skin" dan "Skin journaling".
   - Mascot dengan educational tip bubble (Bahasa Indonesia).

2. **Choose Product** (`ChooseProductView`)
   - Search bar + list produk sample (brand A-D).
   - Single-select dengan radio indicator.
   - Continue ke Journey Detail.

3. **Journey Detail** (`JourneyDetailView`)
   - Tampilkan produk yang dipilih.
   - Jelaskan 2 milestones: Compatibility Check (2 minggu), Results Check.
   - CTA "Start journey" -> buat `SkincareJourney` baru -> navigate ke Main Journey.

4. **Main Journey** (`JourneyMainView`)
   - Title: "Your skin from time to time".
   - Photo progress placeholder + "Add Image" -> Camera flow.
   - Milestone card dengan timeline + CTA "add your skincare journey" / "Complete milestone check".

5. **Camera Flow** (`CameraFlowView`)
   - Guide screen (Indonesian: "Posisikan wajahmu pada frame").
   - Face outline overlay (custom `FaceOutline` view).
   - Confirmation "Nicely captured!" dengan Retake / Use This Photo.
   - MVP: simulated capture (belum integrasi AVCaptureSession).

6. **Journal Entry** (`JournalEntryView`)
   - Date header + milestone title.
   - Face outline + quick tags (Dry/Oily/Breakout/Sensitive/Glowing).
   - Prompt "How's your skin today?" + ruled-paper text editor.
   - Save ke `journalEntries`.

7. **Self Assessment** (`SelfAssessmentView`)
   - Step indicator 3/3.
   - Mood scale 5 pilihan (emoji + label).
   - Symptom multi-select (New breakouts, Dryness, Redness, Itching, New acne, None).
   - Optional note.
   - Submit -> update entry + complete current milestone.

## Catatan Penting

- Onboarding skin concerns (gambar 8.1—8.4) telah dihapus sesuai permintaan.
- Entry point app sekarang adalah `SkinJournalMainView` (main page dengan empty/active state).
- Tap "Skin journaling" dari main page akan masuk ke flow Choose Product → Journey Detail → Main Journey.
- `latestJourney` dan `journeys` diakses via `SkinJournalStore`.
- Update state journey pakai `store.updateLatestJourney { journey in ... }`.

## Build & Run

```bash
cd /Users/ibal/Documents/C4-MySkin
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project C4-MySkin.xcodeproj -scheme C4-MySkin \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

## Riwayat Perubahan

- 2026-08-09: Implementasi fitur SkinJournal dari desain Sketch — choose product, journey detail, main journey, camera flow, journal entry, self assessment. Build sukses.
- 2026-08-09: Onboarding skin concerns (gambar 8.1—8.4) dihapus dari flow.
- 2026-08-09: Tambah Main Page (`SkinJournalMainView`) dengan empty state & active milestone card sebelum masuk ke jurnal flow.
- 2026-08-10: Tambah skill `ios-hig-design` (wondelai/skills/ios-hig-design). Mengganti tampilan `SkinJournalMainView` & `MascotBubble` dengan versi high-fidelity berwarna (gradient background, asset mascot blue, asset bubble action buttons, warm yellow card, speech bubble stroke) & respon haptic feedback.

