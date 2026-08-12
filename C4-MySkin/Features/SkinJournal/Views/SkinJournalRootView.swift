//
//  SkinJournalRootView.swift
//  C4-MySkin
//

import SwiftUI
import AVFoundation

struct SkinJournalRootView: View {
    @State private var viewModel = SkinJournalRootViewModel()
    @State private var path = NavigationPath()
    @State private var selectedProduct: SkincareProduct?

    var body: some View {
        NavigationStack(path: $path) {
            SkinJournalMainView(
                journey: viewModel.latestJourney,
                onSkinJournaling: { path.append(SkinJournalRoute.mainJourney) },
                onProductValidation: { path.append(SkinJournalRoute.productValidation) },
                onProfile: { path.append(SkinJournalRoute.skinProfile) }
            )
            .navigationDestination(for: SkinJournalRoute.self) { route in
                switch route {
                case .skinProfile:
                    let latestImageName = viewModel.latestJourney?.progressPhotos.last?.imageName
                        ?? viewModel.latestJourney?.journalEntries.compactMap(\.imageName).last
                    SkinProfileView(
                        userName: "POLO",
                        skinType: "Dry",
                        sensitivity: "Moderate",
                        skinConcern: "_",
                        latestImageName: latestImageName,
                        onRetakeTest: {
                            // Retake skin test action
                        }
                    )
                case .mainJourney:
                    // "Your skin from time to time" — empty/active state
                    let journey = viewModel.latestJourney ?? SkincareJourney(product: SkincareProduct.samples[0])
                    JourneyMainView(
                        journey: journey,
                        isJourneyActive: viewModel.latestJourney != nil,
                        onAddImage: {
                            CameraSessionManager.shared.prepare()
                            path.append(SkinJournalRoute.camera)
                        },
                        onStartAssessment: {
                            let imageName = viewModel.latestJourney?.progressPhotos.last?.imageName
                            path.append(SkinJournalRoute.selfAssessment(imageName: imageName))
                        },
                        onChooseProduct: {
                            path.append(SkinJournalRoute.chooseProduct(imageName: nil))
                        },
                        onViewDetail: {
                            path.append(SkinJournalRoute.journeyDetail(hideProgressBar: false, initialIndex: nil))
                        },
                        onViewHistory: {
                            path.append(SkinJournalRoute.historyJournaling)
                        },
                        onViewCalendar: {
                            path.append(SkinJournalRoute.calendarJournaling)
                        }
                    )

                case .journeyDetail(let hideProgressBar, let initialIndex):
                    let journey = viewModel.latestJourney ?? SkincareJourney(product: SkincareProduct.samples[0])
                    JourneyDetailView(journey: journey, initialIndex: initialIndex, hideProgressBar: hideProgressBar)

                case .calendarJournaling:
                    let journey = viewModel.latestJourney ?? SkincareJourney(product: SkincareProduct.samples[0])
                    SkinJournalCalendarView(
                        journey: journey,
                        onSelectDateEntry: { entry, entryIndex in
                            path.append(SkinJournalRoute.journeyDetail(hideProgressBar: true, initialIndex: entryIndex))
                        }
                    )

                case .historyJournaling:
                    HistorySkinJournalingView(
                        journeys: viewModel.journeys,
                        onSelectJourney: { selectedJourney in
                            path.append(SkinJournalRoute.journeyDetail(hideProgressBar: false, initialIndex: nil))
                        }
                    )

                case .chooseProduct(let imageName):
                    ChooseProductView(
                        selectedProduct: $selectedProduct,
                        onContinue: {
                            guard let product = selectedProduct else { return }
                            path.append(SkinJournalRoute.selectedProduct(product: product, imageName: imageName))
                        }
                    )

                case .selectedProduct(let product, let imageName):
                    SelectedProductView(
                        product: product,
                        onStartJourney: {
                            viewModel.addJourney(SkincareJourney(product: product))
                            CameraSessionManager.shared.prepare()
                            path.append(SkinJournalRoute.camera)
                        }
                    )

                case .camera:
                    CameraFlowView { imageName in
                        if !imageName.isEmpty {
                            viewModel.updateLatestJourney { j in
                                j.progressPhotos.append(
                                    ProgressPhoto(date: Date(), imageName: imageName, milestoneOrder: 1)
                                )
                            }
                            // Balik langsung ke JourneyMainView (tanpa kuesioner dulu)
                            while path.count > 1 {
                                path.removeLast()
                            }
                        } else {
                            path.removeLast()
                        }
                    }

                case .selfAssessment(let imageName):
                    // Kuesioner 3 langkah
                    SelfAssessmentView { skinCondition, howItFeels, whatYouNoticed in
                        path.append(SkinJournalRoute.journalEntry(
                            imageName: imageName,
                            skinCondition: skinCondition,
                            howItFeels: howItFeels,
                            whatYouNoticed: whatYouNoticed
                        ))
                    } onBack: {
                        path.removeLast()
                    }

                case .journalEntry(let imageName, let skinCondition, let howItFeels, let whatYouNoticed):
                    let journey = viewModel.latestJourney ?? SkincareJourney(product: SkincareProduct.samples[0])
                    JournalEntryView(
                        milestoneTitle: "Milestone \(journey.milestones.first { !$0.isCompleted }?.order ?? 1)",
                        imageName: imageName,
                        skinCondition: skinCondition,
                        howItFeels: howItFeels,
                        whatYouNoticed: whatYouNoticed
                    ) { entry in
                        viewModel.updateLatestJourney { j in
                            j.journalEntries.append(entry)
                        }
                        // Balik ke "Your skin from time to time" (mainJourney)
                        while path.count > 1 {
                            path.removeLast()
                        }
                    } onBack: {
                        path.removeLast()
                    }

                case .productValidation:
                    ProductValidationPlaceholderView {
                        path.removeLast()
                    }
                }
            }
            .task {
                #if !targetEnvironment(simulator)
                // Warm-up discovery kamera di app start — call pertama
                // AVCaptureDevice.default lambat; dengan ini call berikutnya
                // (saat "Add Photos") langsung cepat.
                DispatchQueue.global(qos: .utility).async {
                    _ = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
                }
                #endif
            }
            .onAppear {
                #if DEBUG
                let args = ProcessInfo.processInfo.arguments
                // Hook pengujian: `xcrun simctl launch <udid> test.C4-MySkin --camera-guide`
                if args.contains("--camera-guide") {
                    CameraSessionManager.shared.prepare()
                    path.append(SkinJournalRoute.camera)
                }
                // Hook pengujian kuesioner:
                // `xcrun simctl launch <udid> test.C4-MySkin --self-assessment`
                if args.contains("--self-assessment") {
                    path.append(SkinJournalRoute.selfAssessment(imageName: nil))
                }
                // Hook pengujian timelapse: buat journey sample (3 foto sintetis)
                // lalu buka halaman "Your skin from time to time" — timelapse
                // inline auto-play tampil di sana.
                // `xcrun simctl launch <udid> test.C4-MySkin --show-timelapse`
                if args.contains("--show-timelapse") {
                    if viewModel.latestJourney == nil {
                        Self.makeSampleJourney(addTo: viewModel)
                    }
                    path.append(SkinJournalRoute.mainJourney)
                }
                // Hook pengujian main page ACTIVE state: journey sample dibuat
                // tapi TETAP di main page (tidak push route).
                // `xcrun simctl launch <udid> test.C4-MySkin --main-active`
                if args.contains("--main-active") {
                    if viewModel.latestJourney == nil {
                        Self.makeSampleJourney(addTo: viewModel)
                    }
                }
                // Hook reproduksi JourneyMainView preview states:
                // `--journey-m1` = "Active State (Milestone 1)", `--journey-m2` = "Milestone 2 State"
                if args.contains("--journey-m1") || args.contains("--journey-m2") {
                    let isM2 = args.contains("--journey-m2")
                    var journey = SkincareJourney(product: SkincareProduct.samples[0])
                    if isM2, let mIndex = journey.milestones.firstIndex(where: { !$0.isCompleted }) {
                        journey.milestones[mIndex].isCompleted = true
                    }
                    if isM2 {
                        journey.journalEntries = [
                            JournalEntry(date: Date(), note: "Progress hari ini bagus banget! Kulit terasa lembab."),
                            JournalEntry(date: Date().addingTimeInterval(86400 * 3), note: "Sore ini habis panas-panasan tapi tidak iritasi.")
                        ]
                        journey.progressPhotos = [
                            ProgressPhoto(date: Date(), imageName: "sample_1", milestoneOrder: 1),
                            ProgressPhoto(date: Date().addingTimeInterval(86400 * 3), imageName: "sample_2", milestoneOrder: 2)
                        ]
                    } else {
                        journey.journalEntries = [
                            JournalEntry(date: Date(), note: "Awal pemakaian produk baru.")
                        ]
                        journey.progressPhotos = [
                            ProgressPhoto(date: Date(), imageName: "sample_1", milestoneOrder: 1)
                        ]
                    }
                    viewModel.addJourney(journey)
                    path.append(SkinJournalRoute.mainJourney)
                }
                #endif
            }
        }
    }

    /// Buat journey sample (3 foto sintetis) untuk DEBUG hook.
    private static func makeSampleJourney(addTo viewModel: SkinJournalRootViewModel) {
        // Journey sample: mulai 21 hari lalu, flag 1 selesai 7 hari
        // lalu → sekarang di Milestone #2, Week 2 (progress 50%).
        var journey = SkincareJourney(
            product: SkincareProduct.samples[0],
            startDate: Date().addingTimeInterval(-21 * 86400)
        )
        if let mIndex = journey.milestones.firstIndex(where: { !$0.isCompleted }) {
            journey.milestones[mIndex].isCompleted = true
            journey.milestones[mIndex].completedDate = Date().addingTimeInterval(-7 * 86400)
        }
        let base = Date().addingTimeInterval(-7 * 86400)
        for i in 0..<3 {
            let name = "captured_face_sample_\(i)"
            if let url = CameraViewModel.imageURL(for: name),
               let image = Self.sampleFaceImage(index: i),
               let data = image.pngData() {
                try? FileManager.default.createDirectory(
                    at: url.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try? data.write(to: url)
            }
            journey.progressPhotos.append(
                ProgressPhoto(date: base.addingTimeInterval(TimeInterval(i) * 3 * 86400), imageName: name)
            )
        }
        viewModel.addJourney(journey)
    }

    /// Foto sintetis untuk DEBUG hook `--show-timelapse`.
    private static func sampleFaceImage(index: Int) -> UIImage? {
        let size = CGSize(width: 720, height: 720)
        let colors: [UIColor] = [.systemTeal, .systemIndigo, .systemPink]
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            colors[index % colors.count].setFill()
            context.fill(CGRect(origin: .zero, size: size))

            UIColor(white: 0.95, alpha: 0.9).setFill()
            UIBezierPath(
                ovalIn: CGRect(x: size.width * 0.28, y: size.height * 0.20, width: size.width * 0.44, height: size.height * 0.55)
            ).fill()

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 44),
                .foregroundColor: UIColor.white,
            ]
            NSString(string: "Sample \(index + 1)").draw(at: CGPoint(x: 40, y: 40), withAttributes: attributes)
        }
    }
}

enum SkinJournalRoute: Hashable {
    case skinProfile
    case chooseProduct(imageName: String?)
    case selectedProduct(product: SkincareProduct, imageName: String?)
    case mainJourney
    case journeyDetail(hideProgressBar: Bool = false, initialIndex: Int? = nil)
    case historyJournaling
    case calendarJournaling
    case camera
    case selfAssessment(imageName: String?)
    case journalEntry(imageName: String?, skinCondition: String, howItFeels: String, whatYouNoticed: String)
    case productValidation
}


#Preview {
    SkinJournalRootView()
}
