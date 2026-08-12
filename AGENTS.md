# C4-MySkin — AGENTS.md

> Dokumen konteks kanonik untuk agent chat berikutnya. Wajib di-update setiap ada perubahan kode signifikan. Riwayat perubahan ada di bagian bawah.

## Overview

C4-MySkin adalah iOS app (SwiftUI, MVVM, feature-based) untuk tracking perjalanan skincare. Saat ini fok utama adalah **SkinJournal** — fitur jurnal & milestone tracking produk skincare berdasarkan desain Sketch di `C4-MySkin/Features/SkinJournal/Sketch/`.

## Stack & Konvensi

- **Bahasa**: Swift 5, SwiftUI, Observation macro (`@Observable`).
- **Animation**: Lottie via SPM (`lottie-ios` 4.6.1) — animasi mascot dari folder `Features/SkinJournal/Lotti/` (format .lottie, dimuat via `DotLottieFile.named`).
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
    ├── SkinProfile/                   # Fitur Profil Kulit: Views/SkinProfileView.swift (Skin Profile Summary)
    └── SkinJournal/
        ├── Components/                # Reusable UI: chips, buttons, timeline, cards, MascotLottieView
        ├── Models/                    # SkinConcern, SkincareProduct, SkincareJourney
        ├── ViewModels/                # One VM per screen/feature
        ├── Views/                     # SwiftUI screens
        ├── Lotti/                     # Animasi Lottie: main.lottie (mascot main page), cutsi nama.lottie
        └── Sketch/                    # Source desain dari Sketch (PNG)
```

## Fitur SkinJournal — Flow

1. **Main Page** (`SkinJournalMainView`)
   - Header: greeting "Hi, POLO!", bookmark icon, profile avatar.
   - Search prompt: "Check active products on you!".
   - Empty state: "No active product yet" card.
   - Active state: Milestone card dengan icon produk, progress dashed line, "Result in 2 weeks".
   - 2 circular action buttons: "Product validation skin" dan "Skin journaling".
   - Mascot Lottie animation dengan educational tip bubble.

2. **Main Journey (Empty State)** (`JourneyMainView`)
   - Menampilkan "Your skin from time to time", box "no photos yet", tombol "Add Photos", serta card kuning pastel **"add your skincare journey"** (`+` icon).
   - Kedua CTA ("Add Photos" & card kuning) -> Camera Flow -> foto -> **Choose Product** (photo-first, tidak ada jalur choose-product-tanpa-foto).

3. **Choose Product** (`ChooseProductView`)
   - Title "Choose your product" & subtitle "Pick a product you want to track".
   - Search bar + list produk dengan radio selection indicator.
   - Tap "Continue" -> buat journey baru langsung (tanpa Journey Detail) -> **Self Assessment**.

4. **Self Assessment** (`SelfAssessmentView`)
   - Step 1: Mood/condition scale.
   - Step 2: Skin reaction scale.
   - Step 3: Symptom multi-select chips + note.
   - Tap "Submit" -> masuk ke Journal Entry.

5. **Journal Entry** (`JournalEntryView`)
   - Tanggal header, foto hasil pemotretan, quick tags summary, dan ruled-paper text editor ("How is your skin condition?").
   - Tap "Save" -> simpan entry (+ foto jika ada) ke journey, selesaikan milestone pertama -> kembali ke `JourneyMainView` dengan foto terpajang & card milestone aktif.

6. **Main Journey (Active State)** (`JourneyMainView`)
   - Menampilkan photo box, tombol "Add Photos", dan card kuning **"Milestone #N"** (dengan sun icon & progress dashed line).
   - Tap "Add Photos" -> Camera Flow -> Self Assessment langsung (tanpa pilih produk, karena journey sudah ada).

7. **Camera Flow** (`CameraFlowView`)
   - Guide screen ("Posisikan wajahmu pada frame" + `FaceOutline`).
   - Confirmation screen ("Nicely captured!" + Retake / Use This Photo).
   - Tap "Use This Photo" -> (a) belum ada journey: Choose Product; (b) journey sudah ada: Self Assessment.

## Catatan Penting

- Entry point app adalah `SkinJournalMainView`.
- Tap "Skin journaling" dari Main Page langsung membuka `JourneyMainView`.
- Alur utama (empty state): Add Photos → Camera → Choose Product → Self Assessment → Journal Entry → kembali ke `JourneyMainView` dengan foto & milestone ter-update → Main Page jadi active state.
- `JourneyDetailView` tidak lagi dipakai di alur navigasi (route `journeyDetail` dihapus); journey dibuat langsung saat "Continue" di Choose Product.
- Jika journey sudah ada (active state), Camera Flow langsung ke Self Assessment tanpa Choose Product.

## Build & Run

```bash
cd /Users/ibal/Documents/C4-MySkin
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project C4-MySkin.xcodeproj -scheme C4-MySkin \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

## Reset Data Simulator (mulai dari awal lagi)

App di-uninstall + install ulang = SEMUA data inputan (journeys, foto, UserDefaults) hilang. Satu perintah:

```bash
cd /Users/ibal/Documents/C4-MySkin
bash reset-sim-data.sh
```

Manual (tanpa script):

```bash
# UDID simulator (biasanya F375CCC0-EB33-41D5-A090-34F7E0AAA058)
UDID=$(xcrun simctl list devices | grep -E "iPhone 17 Pro \(" | grep -oE "[0-9A-F-]{36}" | tail -1)
xcrun simctl terminate "$UDID" test.C4-MySkin 2>/dev/null
xcrun simctl uninstall "$UDID" test.C4-MySkin
xcrun simctl install "$UDID" ~/Library/Developer/Xcode/DerivedData/C4-MySkin-*/Build/Products/Debug-iphonesimulator/C4-MySkin.app
xcrun simctl launch "$UDID" test.C4-MySkin
```

Catatan: `simctl terminate` itu SIGKILL → UserDefaults TIDAK ter-flush ke disk; data tersimpan normal saat app ditutup via UI (swipe up) atau dihentikan aplikasi lain. DEBUG hook (`--main-active`, `--show-timelapse`, `--self-assessment`, `--camera-guide`) adalah cara andal menyuntik data sample tanpa harus input manual.

## Riwayat Perubahan

- 2026-08-09: Implementasi fitur SkinJournal dari desain Sketch — choose product, journey detail, main journey, camera flow, journal entry, self assessment. Build sukses.
- 2026-08-09: Onboarding skin concerns (gambar 8.1—8.4) dihapus dari flow.
- 2026-08-09: Tambah Main Page (`SkinJournalMainView`) dengan empty state & active milestone card sebelum masuk ke jurnal flow.
- 2026-08-10: Tambah skill `ios-hig-design` (wondelai/skills/ios-hig-design). Mengganti tampilan `SkinJournalMainView` & `MascotBubble` dengan versi high-fidelity berwarna (gradient background, asset mascot blue, asset bubble action buttons, warm yellow card, speech bubble stroke) & respon haptic feedback.
- 2026-08-11: Tambah animasi mengambang (naik-turun, staggered) pada 2 bubble action button di main page (`ActionBubbleButton` — offset + repeatForever easeInOut, respect Reduce Motion). Jarak antar bubble 24→48pt.
- 2026-08-11: Integrasi Lottie via SPM (`lottie-ios` 4.6.1, ditambah manual di project.pbxproj). Komponen baru `MascotLottieView` (Components/) memutar `main.lottie` (mascot, loop, respect Reduce Motion = frame statis) menggantikan `Image("MascotBlue")` di main page. Build sukses & terverifikasi di simulator.
- 2026-08-11: Mengganti tampilan 3 halaman jurnal (Choose Product, Journey Detail, dan Main Journey) menjadi versi berwarna high-fidelity (background ice-blue gradient `#F0F7FD`, border stroke `#4A90E2`, tombol pill sky-blue `#629CEE`, card produk jar graphic, dan card milestone kuning pastel `#FCE6A9`). Build sukses & terverifikasi.
- 2026-08-11: Update alur navigasi dari tombol "Skin journaling" di Main Page agar sesuai dengan diagram alur 2-baris (Empty Journey State → Choose Product → Journey Detail → Camera Flow → 3-Step Self Assessment → Journal Entry → Active Journey State dengan foto ter-update → Main Page terisi Milestone). Build sukses.
- 2026-08-11: Main page dikunci (`.scrollDisabled(true)`); kartu Active = 130pt sama dengan Empty State (mascot tidak geser antar state); konten diberi `.zIndex(1)` agar tidak ketimpa mascot.
- 2026-08-11: Ubah alur SkinJournal: foto → Choose Product → Self Assessment (3 langkah) → Journal Entry → balik ke `JourneyMainView` dengan foto → Main Page active. Route `journeyDetail` dihapus; journey dibuat saat "Continue" di Choose Product; foto dibawa via route (`imageName: String?`); active state melewati Choose Product.
- 2026-08-11: Update layar Camera Guide (`CameraGuideView`) & Photo Confirmation (`PhotoConfirmationView`) dengan aset vektor `FaceOutline` terbaru yang terpusat pas di tengah frame untuk alignment timelapse foto wajah secara konsisten. Build sukses.
- 2026-08-11: Implementasi live camera frame 1:1 (`CameraPreviewView`) dengan overlay `FaceOutline` samar (`opacity: 0.35`), deteksi posisi wajah terpusat via Vision framework (`VNDetectFaceRectanglesRequest`), aktivasi kondisional tombol "Take Photo" saat wajah di tengah, dan halaman konfirmasi hasil foto (`PhotoConfirmationView`). Build sukses.
- 2026-08-11: Upgrade kamera: frame 1:1 FULL-WIDTH layar (bukan kotak 280pt); deteksi wajah dicocokkan ke `guideRect` (area FaceOutline di tengah, toleransi center + ukuran); capture frame ASLI (crop 1:1 tengah, selfie mirror, `captureRequest` binding); foto disimpan persisten ke `Documents/Photos/` via `CameraViewModel` (helper `loadImage`/`imageURL`); `ProgressPhotoCard` & `JournalEntryView` (param `imageName`) kini menampilkan foto hasil capture; `NSCameraUsageDescription` ditambahkan; DEBUG hook `--camera-guide` untuk testing langsung halaman kamera.
- 2026-08-11: Fix kamera: `sessionPreset` .photo → .high (kompatibel video output); `CameraContainerView.layoutSubviews` menjaga frame preview layer (fix preview hitam); `coordinator.parent = self` di `updateUIView` (fix captureRequest stale → tombol Take Photo sekarang benar-benar capture); border biru frame dihapus; nama file foto memuat timestamp (`yyyyMMdd_HHmmss`).
- 2026-08-11: Fitur TIMELAPSE (`TimelapseView`, push page): crossfade fade in/out MURNI (tanpa zoom) via `.task(id:)` + `withAnimation(.easeInOut)`, foto urut waktu (terlama→terbaru) dari `Documents/Photos`, label tanggal + indikator n/total, kontrol interval 0.5×/1×/2×/4× + Play/Pause. Tombol "View Timelapse" di `JourneyMainView` aktif saat ≥2 foto. DEBUG hook `--show-timelapse` (generate 3 foto sintetis + journey sample lalu buka timelapse).
- 2026-08-11: Fix orientasi foto: buffer video output TIDAK di-mirror (`isVideoMirrored = false`, raw sensor) — mirror cukup sekali via `.oriented(.leftMirrored)` saat capture (sebelumnya double-mirror → foto kebalik); preview layer di-mirror eksplisit (`isVideoMirrored = true`) supaya tampilan selalu cocok dengan hasil foto. Deteksi wajah di-longgarkan: minimum ukuran wajah 0.55→0.25× guide + toleransi center 0.08/0.09→0.09/0.10 — wajah terdeteksi dari jarak lebih jauh.
- 2026-08-11: Fix lag buka kamera: permission diminta SEGERA (alert muncul tanpa menunggu discovery); `AVCaptureDevice.default` + setup session dipindah ke background queue (`setupCamera`) — tidak lagi memblokir main thread saat `makeUIView` (sebelumnya push halaman kamera tersendat ratusan ms–detik); `CameraContainerView` menampilkan spinner + label "Menyiapkan kamera…" selama session belum berjalan, disembunyikan setelah `startRunning`.
- 2026-08-11: Refactor kamera → `CameraSessionManager` (SHARED, pre-warm): session dibuat & distart saat "Add Photos" DITEKAN (sebelum halaman muncul) — preview langsung tampil tanpa warm-up; timeout 6 detik (spinner tidak pernah selamanya → state `.failed` + tombol "Coba Lagi"); `stop()` saat keluar alur kamera (cegah session menumpuk/konflik kamera); `CameraOutputProxy` (nonisolated) pegang frame terbaru + handler deteksi; `CameraPreviewView` jadi tipis (attach layer + Vision + capture); `CameraGuideView` observasi state (spinner/error/denied overlay); warm-up discovery `AVCaptureDevice.default` di app start.
- 2026-08-11: Fix crash `NSInvalidArgumentException` (setVideoMirrored saat automaticallyAdjustsVideoMirroring = YES): `automaticallyAdjustsVideoMirroring = false` WAJIB di-set DULU sebelum `isVideoMirrored` (di output connection manager & preview layer) — default YES untuk kamera depan.
- 2026-08-11: Timelapse pindah INLINE ke `JourneyMainView` (bukan halaman terpisah): `PhotoTimelapseCard` (Components/) auto-play crossfade speed 2× (interval 1.0s), tanggal foto di KANAN BAWAH, nama produk terpilih di KIRI ATAS; empty state tetap `ProgressPhotoCard` ("no photos yet"); tombol "View Timelapse", route `.timelapse`, dan `TimelapseView.swift` DIHAPUS; hook `--show-timelapse` kini membuka `.mainJourney` (sample data tetap dibuat).
- 2026-08-11: Algoritma MILESTONE/FLAG di main page (`MilestoneProgress` di Models + rewrite `ActiveMilestoneCard`): tiap FLAG = periode 2 minggu (14 hari); upload foto yang menyelesaikan milestone = flag selesai → lanjut flag berikutnya (nomor flag dari milestone pertama yang belum selesai; `ProgressPhoto.milestoneOrder` dicatat saat save); minggu berjalan dihitung dari waktu (reminder "Week X of N"); kartu menampilkan timeline bendera (selesai=terisi centang, aktif=highlight), progress bar menuju upload berikutnya, teks "Next: dd MMM" / "Upload foto sekarang!" saat overdue, dan state "Journey Complete" saat semua flag selesai. Tinggi kartu tetap 130pt (saklak).
- 2026-08-11: Mascot KUESIONER disinkronkan dengan main page: `SpeechBubbleView` (tanpa stroke) diganti `MascotBubble` (white + stroke abu-abu 3.5) — sebelumnya bubble TERPOTONG tidak tampil (zIndex salah di level dalam + ZStack alignment); sekarang bubble via `.overlay(alignment: .topTrailing)` (pasti di atas), `MascotLottieView(width: 560)` (sebelumnya 460) dengan `offset(y: 140)` dalam frame 300 ter-clip → kepala + mata + pipi + badan atas terlihat, badan bawah terpotong (sama seperti main page). `zIndex(10)` bubble main page dipindah ke level HStack. DEBUG hook baru `--self-assessment` untuk testing halaman kuesioner.
- 2026-08-11: Mascot diganti ke GIF (`MascotGIFView`, komponen baru user, ImageIO): `main.gif` DI-RENDER ULANG dari Lottie source (`main.lottie`/`Main Scene.json`, aset PNG 3508x2480) ke 1024x1024 (150 frame @30fps, transparan) via lottie-web + puppeteer-core (Chrome terpasang) + ffmpeg — sebelumnya GIF cuma 150x150 → upscale 3.7x di frame 560pt = tampak pecah/"gedee". Fix lanjutan: ffmpeg mereduksi frame (150→37 via dedup) → animasi kecepatan tidak normal; perbaikan dengan `palettegen=stats_mode=full` + `-gifflags -transdiff` untuk mempertahankan seluruh 150 frame @33ms (30fps, 5s loop). Ukuran mascot di main page diperkecil dari width: 560 → 480 untuk menyamakan proporsi dengan Lottie sebelumnya. Backup GIF awal: `Lotti/main_150_backup.gif`.
- 2026-08-11: Update algoritma milestone container: 2 minggu pertama menampilkan label "Result in 2 weeks", setelah 2 minggu (atau flag selanjutnya) otomatis mengonversi akumulasi 2-minggu menjadi "Week X of N" berdasarkan expected duration produk; klik container di main page langsung direct ke `JourneyMainView` ("Your skin from time to time"). Build sukses.
- 2026-08-11: Update alur SkinJournal: saat pertama kali masuk "Skin journaling", aplikasi membuka `JourneyMainView` dalam state EMPTY ("no photos yet" + container "add your skincare journey"). Klik container/Add Photos di empty state → ke Choose Product → pilih produk → balik ke `JourneyMainView` (sekarang ACTIVE dengan kartu Milestone #1) → baru setelah itu pengguna bisa ambil foto via "Add Photos". Build sukses.
- 2026-08-11: Integrasi Lottie mascot (`MascotLottieView`) di bagian bawah layar kuesioner (`SelfAssessmentView`) menggantikan dome graphic placeholder, persis sama dengan mascot animasi di Main Page, dengan speech bubble text melayang di atasnya. Build sukses.
- 2026-08-11: Fix posisi mascot kuesioner & hapus outline bubble message: mengganti komponen dengan `SpeechBubbleView` (shape putih + shadow, tanpa stroke border), serta menyesuaikan offset & frame `MascotLottieView(width: 420)` agar kepala, mata, pipi, dan ekspresi lucu mascot tampil jelas di bawah kuesioner. Build sukses.
- 2026-08-11: Refactor `QuestionnaireMascotBottomView` di `SelfAssessmentView.swift`: speech bubble `SpeechBubbleView` (putih bersih tanpa stroke, shadow halus, tail menunjuk ke bawah-kiri) kini 100% tampil utuh tanpa terpotong layout clipping; Lottie mascot `DotLottieFile.named("main")` beranimasi halus dengan frame pas (`width: 320, height: 165, alignment: .top`) menampilkan wajah, mata, pipi, dan ekspresi lucu mascot di bawah kuesioner. Build sukses.
- 2026-08-11: Migrasi animasi mascot dari Lottie ke `main.gif` (`MascotGIFView.swift` di Components/): memuat & memutar `main.gif` secara native via `CGImageSource` (ImageIO) di `SkinJournalMainView` dan `SelfAssessmentView`. Menghormati Reduce Motion & fallback path loading jika diperlukan. Build sukses.
- 2026-08-11: Fix layout `MascotGIFView`: membatasi `maxWidth: .infinity` pada kontainer transparan agar gambar GIF tidak mengekspansi lebar layar (`width: 480`), mencegah seluruh komponen halaman terdorong keluar layar, dan menyesuaikan proporsi tinggi mascot di Main Page. Build sukses.
- 2026-08-11: Penyesuaian ukuran mascot: mengecilkan proporsi visual `MascotGIFView` di Main Page (lebar `360pt`) dan Kuesioner (lebar `260pt`) agar mascot tampil imut, rapi, dan seimbang dengan seluruh komponen UI halaman. Build sukses.
- 2026-08-11: Fix proporsi mascot GIF: menghapus `offset(y: -20)` dan menset `MascotGIFView(width: 200)` di Main Page & `width: 180` di Kuesioner sehingga seluruh kepala, mata, pipi, dan ekspresi imut mascot tampil utuh tanpa ter-zoom besar/memenuhi layar. Build sukses.
- 2026-08-11: Re-scaling file `main.gif`: mengecilkan subjek mascot di dalam 149 frame GIF sebesar 50% dan menambahkan padding transparan yang rapi (ukuran file turun dari 9.1MB ke 470KB). Seluruh gambar mascot (kepala, telinga, mata berkedip, pipi) kini tampil utuh dan imut tanpa ter-crop raksasa. Build sukses.
- 2026-08-11: Fix kecepatan animasi GIF: mengubah durasi antar frame di `main.gif` dan `MascotGIFView` dari ~35ms (terlalu kencang/hyperactive) menjadi 138ms (~4.96 detik total durasi animasi), sehingga mascot berkedip halus dan tenang seperti animasi Lottie aslinya. Build sukses.
- 2026-08-11: Mengembalikan ukuran visual `MascotGIFView` ke ukuran besar (`width: 480` di Main Page & `width: 360` di Kuesioner) dengan kecepatan animasi normal, halus, dan stabil tanpa melebarkan kontainer induk. Build sukses.
- 2026-08-11: Fix final framing mascot GIF: mengecilkan subjek mascot menjadi 35% di dalam kanvas 1024x1024 dengan margin transparan yang seimbang dan menghapus offset negatif clipping. Seluruh gambar mascot (kepala, telinga, mata berkedip, pipi) kini tampil utuh, jernih, dan tidak lagi ter-zoom raksasa di simulator/perangkat. Build sukses.
- 2026-08-11: Membesarkan ukuran mascot visual: menset `MascotGIFView(width: 380)` di Main Page dan `width: 300` di Kuesioner sesuai permintaan pengguna, dengan framing utuh dan animasi halus tanpa clipping. Build sukses.
- 2026-08-11: Pembesaran mascot lanjutan: menset `MascotGIFView(width: 440)` di Main Page dan `width: 350` di Kuesioner sesuai permintaan pengguna. Build sukses.
- 2026-08-11: Membesarkan ukuran mascot di Main Page: menset `MascotGIFView(width: 500)` di `SkinJournalMainView.swift` sesuai permintaan pengguna. Build sukses.
- 2026-08-11: Fix layout rapi di Main Page: mengunci kontainer `MascotGIFView` ke lebar layar (`maxWidth: .infinity`) dengan tinggi terbatas `width * 0.40` + clipping top offset background. Header "Hi, POLO!", search bar, kartu, dan 2 tombol action kembali tampil 100% utuh, rapi, dan terpusat di layar iPhone tanpa terdorong ke kiri; speech bubble menunjuk tepat ke kepala mascot. Build sukses.
- 2026-08-11: Sesuai Gambar Referensi: Crop presisi `main.gif` (895x760, rasio 1.18:1) tanpa padding transparan buatan; `MascotGIFView` menskala 100% karakter mascot (curl rambut, kepala, mata, pipi merah, dan dagu bawah) tanpa terpotong (`width: 360`, rasio 760/895). Speech bubble ditarik tumpang tindih presisi (`spacing: -110`) persis 100% cocok dengan desain referensi pengguna. Build sukses.
- 2026-08-11: Skala Mascot Dikecilkan 50%: Menset `MascotGIFView(width: 180)` di Main Page dan `width: 150` di Kuesioner dengan penyesuaian spacing bubble (`spacing: -35`), mascot tampil imut, utuh 100%, dan beranimasi halus. Build sukses.
- 2026-08-11: Fix bug intrinsicContentSize pada UIImageView di MascotGIFView: override `intrinsicContentSize` ke `.zero` dan set priority ke `.defaultLow`, sehingga SwiftUI `.frame(width: 180)` dipatuhi 100% tanpa lagi dipaksa mengembang ke ukuran asli GIF (895x760). Mascot di Halaman Utama kini tampil kecil, imut, dan utuh 100%. Build sukses.
- 2026-08-11: Fix animasi GIF tidak bergerak: rewrite `MascotGIFView` menggunakan `GIFPlayer` (`ObservableObject`) dengan Timer-based frame stepping per-frame delay dari metadata GIF (menggantikan `UIImageView.animationImages` yang tidak andal di SwiftUI lifecycle). `@StateObject private var player = GIFPlayer()` di-drive setiap frame via `Timer.scheduledTimer` → `@Published var currentFrame: UIImage?` → di-render oleh `Image(uiImage:)` di SwiftUI. Build sukses.
- 2026-08-11: Restrukturisasi layout Main Page sesuai desain referensi: mascot GIF besar (`UIScreen.main.bounds.width * 1.1`) mengisi bagian bawah layar via ZStack background layer (hanya kepala+mata terlihat, badan terpotong bawah layar); speech bubble terpusat di atas area mata mascot; konten (header, search, kartu, action buttons) tetap di layer atas. `mascotSection` property dihapus.
- 2026-08-11: SAKLAK kartu main page diverifikasi ulang setelah user revert desain kartu milestone (badge "Active" + timeline jar→flag, natural ~195pt): `EmptyStateCard` & `ActiveMilestoneCard` keduanya di-set `.frame(height: 195)` + `.padding(.bottom, 16)` → total 211pt identik. Verifikasi pixel-precise (centroid tombol action): dengan Reduce Motion aktif kedua state IDENTIK 0.0pt (Lottie berhenti); tanpa Reduce Motion beda ≤4pt hanya dari animasi Lottie yang menembus area tombol. Kesimpulan: layouting main page tidak berubah antar state. Catatan: `xcrun simctl spawn <udid> defaults write com.apple.Accessibility ReduceMotionEnabled -bool true/false` untuk mematikan animasi saat verifikasi layout deterministik.
- 2026-08-11: Penyesuaian Main Page agar MIRIP referensi desain: (1) avatar header Circle abu-abu → SF Symbol `person.crop.circle.fill`; (2) tombol action kiri 3 baris → 2 baris ("Product\nvalidation skin"); (3) mascot GIF width 1.1× → 0.92× lebar layar (tidak lagi terpotong samping, margin tipis kiri/kanan); (4) judul kartu aktif "Milestone #N" → **"Monitoring Period"**; (5) icon produk: jar.fill biru dalam box putih → icon `product.iconName` PUTIH langsung di kartu (tanpa box); (6) progress bar solid → **DASHED** putih + segmen biru + icon flag di ujung. DEBUG hook baru `--main-active` (buat journey sample tanpa push route, untuk test main page ACTIVE). Catatan: `simctl terminate` = SIGKILL → UserDefaults tidak ter-flush; hook adalah cara andal melihat state. Build sukses & terverifikasi di simulator.
- 2026-08-11: Revert penggunaan `MascotGIFView` kembali ke `MascotLottieView` (`main.lottie`) di `SkinJournalMainView.swift` dan `SelfAssessmentView.swift`. Build sukses.
- 2026-08-11: Membesarkan ukuran `MascotLottieView` di Main Page dari `0.92x` ke `1.3x` lebar layar (`UIScreen.main.bounds.width * 1.3`) dan mengaktifkan kembali speech bubble `MascotBubble`. Build sukses.
- 2026-08-11: Integrasi Lottie mascot (`MascotLottieView`) di bagian bawah layar kuesioner (`SelfAssessmentView`) menggantikan dome graphic placeholder, persis sama dengan mascot animasi di Main Page, dengan speech bubble text melayang di atasnya. Build sukses.
- 2026-08-11: Refactor `QuestionnaireMascotBottomView` di `SelfAssessmentView.swift`: menghapus pembatasan tinggi `frame(height: 240)` dan `.clipped()` yang memotong bagian bawah mascot, menyesuaikan `MascotLottieView(width: 320)` agar seluruh tubuh dan ekspresi mascot tampil utuh dan proporsional. Build sukses.
- 2026-08-11: Memposisikan mascot di `SelfAssessmentView.swift` lebih ke bawah (`frame(height: 200)` + `offset(y: 140)` + `.clipped()`) sehingga mascot dan speech bubble tidak lagi menutupi kartu pilihan kuesioner di tengah layar. Build sukses.
- 2026-08-11: Perbaikan final mascot kuesioner (`SelfAssessmentView.swift`): menyesuaikan `MascotLottieView(width: 240)` tanpa clipping dan tanpa offset berlebih. Mascot kini tampil utuh 100% (tidak terpotong di bawah) dan posisinya pas di bawah 5 opsi kuesioner tanpa menutupi pilihan sama sekali. Build sukses.
- 2026-08-11: Update Main Page (`SkinJournalMainView.swift`): menambah jarak antar kartu milestone container dan tombol action bubble (`padding(.top, 40)`), serta mengganti komponen pesan purging menggunakan `SpeechBubbleView` (komponen speech bubble bersih dari kuesioner) yang diposisikan di sebelah kanan atas mascot (`padding(.trailing, 24)`). Build sukses.
- 2026-08-11: Redesain kartu milestone aktif (`ActiveMilestoneCard` di `SkinJournalMainView.swift`) persis sesuai gambar referensi: pill badge "Active" sky blue di kiri atas, judul "Milestone #N", serta timeline horizontal berisi lingkaran ikon produk jar biru (`Start dd/MM/yyyy`), garis putus-putus tebal biru (`StrokeStyle(lineWidth: 3.5, dash: [8, 5])`), dan ikon bendera biru (`Results in 2 weeks`) dengan mempertahankan 100% algoritma `MilestoneProgress`. Build sukses.
- 2026-08-11: Mengganti garis putus-putus di `ActiveMilestoneCard` dengan custom progress bar slider berisi warna biru tua (`Color(red: 0.16, green: 0.35, blue: 0.54)`), terpusat rapi dan terisi secara dinamis mengikuti progress perjalanan milestone. Build sukses.
- 2026-08-11: Menambahkan indikator dot bulat ber-ring sky blue (`Circle` fill biru tua + ring `stroke` sky blue) pada ujung filled progress bar `ActiveMilestoneCard`, persis mengikuti gaya indikator dot pada slider kuesioner (`QuestionnaireStepSlider`). Build sukses.
- 2026-08-11: Menyesuaikan panjang (length) track slider `ActiveMilestoneCard` dengan menambahkan margin inset horizontal (`trackInset: 16pt`) agar slider tidak terlalu panjang dan menyisa ruang bernapas yang rapi terhadap ikon Start & Results. Build sukses.
- 2026-08-11: Penyesuaian top bar `JourneyMainView.swift`: mengubah top padding dari 8pt ke 50pt (`.padding(.top, 50)`) agar sejajar dengan posisi header Halaman Utama dan memberikan jarak vertikal 12pt yang rapi di bawah tombol kembali, sehingga judul "Your skin from time to time" tidak mepet atau berdesakan dengan tombol kembali. Build sukses.
- 2026-08-11: Integrasi `ActiveMilestoneCard` di `JourneyMainView.swift`: menggantikan `ActiveMilestoneYellowCard` lama dengan komponen `ActiveMilestoneCard` yang sama persis seperti di Halaman Utama (Main Page) saat journey aktif, lengkap dengan pill badge "Active", timeline horizontal slider, dan ikon bendera. Build sukses.
- 2026-08-11: Menambahkan layar baru `SelectedProductView.swift` (sesuai gambar referensi mockup pengguna): menampilkan ringkasan produk terpilih dalam kartu ber-border biru, ringkasan 2 milestone (Compatibility Check & Results Check), kartu pengingat ("for the best results, take a progress photo every 2 weeks"), dan tombol pill sky blue **"Start Journey"**. Alur navigasi diperbarui dari `ChooseProductView` -> `SelectedProductView` -> `Start Journey` -> `SelfAssessmentView` / `JourneyMainView`. Build sukses.
- 2026-08-11: Menambahkan banner prompt `NoJourneyToastCard` di `JourneyMainView.swift` (sesuai gambar referensi mockup pengguna): ketika pengguna menekan tombol "Add Photos" saat belum menambahkan produk skincare, banner gelap bertuliskan **"You should add your journey first!"** dan subtitle *"tap button “add your skincare journey” to begin"* akan muncul secara halus dengan animasi di bawah kartu container milestone. Build sukses.
- 2026-08-11: Redesain `JournalEntryView.swift` persis sesuai gambar referensi: (1) Judul header teratas menampilkan nama milestone ongoing (misal **"Milestone #2"**) dengan top padding `50pt`; (2) Menampilkan foto hasil capture dengan pill overlay tanggal (`"04 Agustus 2026"`) di kanan bawah; (3) Detail hasil kuesioner rapi 2 kolom terpisah (kolom kiri sky blue 140pt, kolom kanan dark blue bold); (4) `YellowRuledPaperEditor.swift` kini 100% responsif—garis bergaris notebook muncul secara dinamis mengikuti jumlah baris teks dan tinggi kontainer membesar tanpa membuat teks bertumpuk. Build sukses.
- 2026-08-11: Update `JournalTimelineHeader` di `JournalEntryView.swift`: mengganti connector garis putus-putus dengan custom progress bar slider berisi warna biru tua (`Color(red: 0.16, green: 0.35, blue: 0.54)`) dan indikator dot ber-ring sky blue persis seperti pada Halaman Utama (Main Page), dengan tetap mempertahankan seluruh ikon bendera, jar, dan ekspresi senyum. Build sukses.
- 2026-08-11: Update layar `JourneyMainView.swift` saat journey aktif (sesuai gambar referensi mockup pengguna): (1) Menambahkan tombol menu titik tiga (`ellipsis`) di kanan atas header bar; (2) Menambahkan garis pemisah divider dan judul section **"Current Skincare Journey"** + nama produk; (3) Menumpuk dua kartu milestone: kartu pastel **Milestone #1 (Active)** dan kartu abu-abu terkunci **Milestone #2 (Upcoming)**. Build sukses.
- 2026-08-11: Re-implementasi `JourneyDetailView.swift` (layar Detail History Journal & Milestone yang telah dijurnalkan, persis sesuai gambar referensi mockup pengguna): (1) Header teratas menampilkan "Milestone #2"; (2) Tombol panah navigasi kiri/kanan (`<` dan `>`) di samping foto untuk membalik halaman antar riwayat jurnal; (3) Detail hasil kuesioner rapi 2 kolom; (4) Notebook card kuning bergaris dengan karakter mascot (`MascotLottieView`) di-overlay di sudut kanan bawah. Menghubungkan klik container milestone di `JourneyMainView.swift` untuk langsung men-direct ke layar detail riwayat ini (`.journeyDetail`). Build sukses.
- 2026-08-11: Update header `JourneyMainView.swift` & membuat `HistorySkinJournalingView.swift` (sesuai gambar referensi mockup pengguna): (1) Mengganti tombol titik tiga (`ellipsis`) di kanan atas header `JourneyMainView` dengan `HistoryButton` berbentuk pill capsule yang memuat SF Symbol `clock.arrow.circlepath` dan teks **"History"**, bergaya outline stroke tebal 2pt persis sama seperti tombol `BackButton`; (2) Membuat layar baru `HistorySkinJournalingView.swift` dengan judul *"History Skin Journaling"*, deskripsi subtitle, dan daftar kartu produk skincare yang pernah dilacak; (3) Menghubungkan klik `HistoryButton` dan kartu produk di histori ke alur navigasi aplikasi (`.historyJournaling` & `.journeyDetail`). Build sukses.
- 2026-08-11: Implementasi Fitur Baru **Skin Profile** (`Features/SkinProfile/Views/SkinProfileView.swift`): (1) Dibuat dalam folder fitur terpisah `Features/SkinProfile/`; (2) Menampilkan judul *"Skin Profile Summary"*, bingkai foto bentuk wajah `FaceOutline`, yellow spiral badge dengan teks **"POLO"** dan karakter mascot (`MascotLottieView`), daftar detail profil kulit (*Skin Type : Dry*, *Sensitivity : Moderate*, *Skin Concern : _*), serta tombol sky blue **"Retake the test"**; (3) Menghubungkan tombol avatar profil di header Main Page (`SkinJournalMainView.swift`) untuk men-direct pengguna langsung ke layar profil ini (`.skinProfile`). Build sukses.
- 2026-08-11: Update header `JourneyMainView.swift` & membuat `SkinJournalCalendarView.swift`: (1) Menambahkan `CalendarButton` lingkaran 42x42 berisi SF Symbol `calendar` (tanpa teks) berdampingan dengan `HistoryButton` di kanan atas header `JourneyMainView`, dengan gaya stroke border 2pt persis sama seperti tombol `BackButton`; (2) Membuat layar kalender baru `SkinJournalCalendarView.swift` ("Journal Calendar") dengan grid hari 1..31 dan penanda bulat biru pada tanggal yang memiliki foto progress/jurnal; (3) Mengeklik tanggal berfoto di kalender akan men-direct pengguna ke `JourneyDetailView` dengan menyembunyikan progress bar atas (`hideProgressBar: true`), hanya menampilkan foto & detail jurnal hari itu. Build sukses.
- 2026-08-12: Refactor feature Onboarding menjadi alur percakapan kontinu (`OnboardingConversationScreen`): step welcome/introduction/skincareHelp/getNamePrompt/personalizationIntro kini berbagi satu container dengan mascot sebagai visual anchor tetap; saat tap, top text dan bottom control fade/slide out, mascot tetap terlihat sambil animation pose berganti, lalu text/control baru fade/slide in. `OnboardingViewModel` menambahkan `isConversationContentVisible`, `advanceConversation()`, dan `submitNameWithConversationTransition()`. Build sukses.
- 2026-08-12: Tambah transisi khusus dari onboarding quiz intro ke Skin Type: saat pengguna tap **"Mulai Kuis"**, text/button fade out, Lottie mascot idle yang sama tetap dirender lalu bergerak turun dan berubah frame/crop ke posisi bawah Skin Type sebelum screen Skin Type muncul. `OnboardingViewModel` menambahkan `isMascotDroppingToQuiz` dan delay transisi 0.42s khusus step `personalizationIntro -> skinType`. Build sukses.










































