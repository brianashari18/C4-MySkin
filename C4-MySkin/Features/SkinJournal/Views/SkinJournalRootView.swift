//
//  SkinJournalRootView.swift
//  C4-MySkin
//

import SwiftUI
import AVFoundation

struct SkinJournalRootView: View {
    @State private var viewModel = SkinJournalRootViewModel(store: .shared)
    @State private var path = NavigationPath()
    @State private var selectedProduct: SkincareProduct?
    @Environment(AppDataService.self) private var dataService

    private var userProfile: UserProfile {
        dataService.fetchOrCreateProfile()
    }

    var body: some View {
        NavigationStack(path: $path) {
            SkinJournalMainView(
                journey: viewModel.latestJourney,
                userName: userProfile.name.isEmpty ? "POLO" : userProfile.name,
                onSkinJournaling: { path.append(SkinJournalRoute.mainJourney) },
                onProductValidation: { path.append(SkinJournalRoute.productValidation) },
                onProfile: { path.append(SkinJournalRoute.skinProfile) }
            )
            .navigationDestination(for: SkinJournalRoute.self) { route in
                switch route {
                case .skinProfile:
                    let concernLabel = userProfile.selectedConcernIDs.isEmpty
                        ? "_"
                        : userProfile.selectedConcernIDs.joined(separator: ", ")
                    let latestImageName = viewModel.latestJourney?.progressPhotos.last?.imageName
                        ?? viewModel.latestJourney?.journalEntries.compactMap(\.imageName).last
                    SkinProfileView(
                        userName: userProfile.name.isEmpty ? "POLO" : userProfile.name,
                        skinType: userProfile.skinTypeRaw ?? "Dry",
                        sensitivity: userProfile.skinSensitivityRaw ?? "Moderate",
                        skinConcern: concernLabel,
                        latestImageName: latestImageName,
                        onRetakeTest: {
                            path.append(SkinJournalRoute.personalization)
                        }
                    )
                case .personalization:
                    let initial = OnboardingPersonalization(
                        skinType: userProfile.skinTypeRaw.flatMap(SkinType.init(rawValue:)),
                        skinSensitivity: userProfile.skinSensitivityRaw.flatMap(SkinSensitivity.init(rawValue:))
                    )
                    PersonalizationView(initialPersonalization: initial) { _ in
                        path.removeLast()
                    }
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
                            path.append(SkinJournalRoute.journeyDetail(journeyID: nil, hideProgressBar: false, initialIndex: nil))
                        },
                        onViewHistory: {
                            path.append(SkinJournalRoute.historyJournaling)
                        },
                        onViewCalendar: {
                            path.append(SkinJournalRoute.calendarJournaling)
                        }
                    )

                case .journeyDetail(let journeyID, let hideProgressBar, let initialIndex):
                    let journey = journeyID.flatMap { viewModel.journey(id: $0) }
                        ?? viewModel.latestJourney
                        ?? SkincareJourney(product: SkincareProduct.samples[0])
                    JourneyDetailView(
                        journey: journey,
                        initialIndex: initialIndex,
                        hideProgressBar: hideProgressBar,
                        onSkipToMilestoneOne: skipToMilestoneOneCompletion,
                        onSkipToMilestoneTwo: skipToMilestoneTwoCompletion
                    )

                case .calendarJournaling:
                    let journey = viewModel.latestJourney ?? SkincareJourney(product: SkincareProduct.samples[0])
                    SkinJournalCalendarView(
                        journey: journey,
                        onSelectDateEntry: { entry, entryIndex in
                            path.append(SkinJournalRoute.journeyDetail(journeyID: nil, hideProgressBar: true, initialIndex: entryIndex))
                        }
                    )

                case .historyJournaling:
                    HistorySkinJournalingView(
                        journeys: viewModel.journeys,
                        onSelectJourney: { selectedJourney in
                            path.append(SkinJournalRoute.journeyDetail(
                                journeyID: selectedJourney.id,
                                hideProgressBar: false,
                                initialIndex: nil
                            ))
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

                case .selectedProduct(let product, _):
                    SelectedProductView(
                        product: product,
                        onStartJourney: {
                            viewModel.addJourney(SkincareJourney(product: product))
                            dataService.saveTrackedProduct(
                                name: product.name,
                                brand: product.brand,
                                category: product.category,
                                imageURL: product.imageURL,
                                slug: product.slug,
                                highlights: product.highlights
                            )
                            CameraSessionManager.shared.prepare()
                            path.append(SkinJournalRoute.camera)
                        }
                    )

                case .camera:
                    CameraFlowView { imageName in
                        if !imageName.isEmpty {
                            // Foto diteruskan ke assessment dan baru disimpan ke
                            // journey bersama journal entry setelah user menekan Save.
                            path.append(SkinJournalRoute.selfAssessment(imageName: imageName))
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
                        var shouldShowMilestoneOneCompletion = false
                        var shouldShowMilestoneTwoCompletion = false
                        viewModel.updateLatestJourney { j in
                            j.journalEntries.append(entry)

                            if let imageName = entry.imageName, !imageName.isEmpty {
                                let milestoneOrder = j.milestones.first { !$0.isCompleted }?.order ?? 2
                                j.progressPhotos.append(
                                    ProgressPhoto(
                                        date: entry.date,
                                        imageName: imageName,
                                        milestoneOrder: milestoneOrder
                                    )
                                )
                            }

                            if let milestoneIndex = j.milestones.firstIndex(where: { $0.order == 1 }),
                               !j.milestones[milestoneIndex].isCompleted,
                               Self.hasReachedMilestoneOneEnd(journey: j, on: entry.date) {
                                j.milestones[milestoneIndex].isCompleted = true
                                j.milestones[milestoneIndex].completedDate = entry.date
                                shouldShowMilestoneOneCompletion = true
                            }

                            if let milestoneIndex = j.milestones.firstIndex(where: { $0.order == 2 }),
                               !j.milestones[milestoneIndex].isCompleted,
                               Self.hasReachedMilestoneTwoEnd(journey: j, on: entry.date) {
                                j.milestones[milestoneIndex].isCompleted = true
                                j.milestones[milestoneIndex].completedDate = entry.date
                                shouldShowMilestoneTwoCompletion = true
                            }
                        }

                        if shouldShowMilestoneTwoCompletion {
                            path.append(SkinJournalRoute.milestoneTwoCompletion)
                        } else if shouldShowMilestoneOneCompletion {
                            path.append(SkinJournalRoute.milestoneOneCompletion)
                        } else {
                            // Balik ke "Your skin from time to time" (mainJourney)
                            while path.count > 1 {
                                path.removeLast()
                            }
                        }
                    } onBack: {
                        path.removeLast()
                    }

                case .milestoneOneCompletion:
                    MilestoneOneCompletionView(
                        onStopJourney: {
                            viewModel.archiveLatestJourney()
                            path = NavigationPath()
                        },
                        onContinueJourney: {
                            while path.count > 1 {
                                path.removeLast()
                            }
                        }
                    )

                case .milestoneTwoCompletion:
                    MilestoneTwoCompletionView { rating in
                        viewModel.finishLatestJourney(rating: rating)
                        path = NavigationPath()
                    }

                case .productValidation:
                    ProductValidationView()
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
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
                // Hook pengujian layar keputusan setelah Milestone 1 selesai:
                // `xcrun simctl launch <udid> test.C4-MySkin --milestone-1-completion`
                if args.contains("--milestone-1-completion") {
                    path.append(SkinJournalRoute.milestoneOneCompletion)
                }
                // Hook pengujian layar akhir perjalanan setelah Milestone 2:
                // `xcrun simctl launch <udid> test.C4-MySkin --milestone-2-completion`
                if args.contains("--milestone-2-completion") {
                    path.append(SkinJournalRoute.milestoneTwoCompletion)
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

    private static func hasReachedMilestoneOneEnd(
        journey: SkincareJourney,
        on date: Date,
        calendar: Calendar = .current
    ) -> Bool {
        guard let targetDate = calendar.date(
            byAdding: .day,
            value: MilestoneProgress.flagDurationDays,
            to: journey.startDate
        ) else {
            return false
        }

        return calendar.startOfDay(for: date) >= calendar.startOfDay(for: targetDate)
    }

    private func skipToMilestoneOneCompletion() {
        guard DemoConfiguration.isEnabled else { return }
        ensureDemoJourneyExists()

        viewModel.updateLatestJourney { journey in
            guard let milestoneIndex = journey.milestones.firstIndex(where: { $0.order == 1 }) else { return }
            journey.startDate = Calendar.current.date(
                byAdding: .day,
                value: -MilestoneProgress.flagDurationDays,
                to: Date()
            ) ?? journey.startDate
            journey.milestones[milestoneIndex].isCompleted = true
            journey.milestones[milestoneIndex].completedDate = Date()

            if let milestoneTwoIndex = journey.milestones.firstIndex(where: { $0.order == 2 }) {
                journey.milestones[milestoneTwoIndex].isCompleted = false
                journey.milestones[milestoneTwoIndex].completedDate = nil
            }
        }

        path.append(SkinJournalRoute.mainJourney)
        path.append(SkinJournalRoute.milestoneOneCompletion)
    }

    private func skipToMilestoneTwoCompletion() {
        guard DemoConfiguration.isEnabled else { return }
        ensureDemoJourneyExists()

        viewModel.updateLatestJourney { journey in
            let now = Date()
            let milestoneOneEnd = Calendar.current.date(
                byAdding: .day,
                value: -(MilestoneProgress.flagDurationDays * 4),
                to: now
            ) ?? now

            if let milestoneOneIndex = journey.milestones.firstIndex(where: { $0.order == 1 }) {
                journey.milestones[milestoneOneIndex].isCompleted = true
                journey.milestones[milestoneOneIndex].completedDate = milestoneOneEnd
            }
            if let milestoneTwoIndex = journey.milestones.firstIndex(where: { $0.order == 2 }) {
                journey.milestones[milestoneTwoIndex].isCompleted = true
                journey.milestones[milestoneTwoIndex].completedDate = now
            }
        }

        path.append(SkinJournalRoute.milestoneTwoCompletion)
    }

    private func ensureDemoJourneyExists() {
        guard viewModel.latestJourney == nil else { return }
        viewModel.addJourney(SkincareJourney(product: SkincareProduct.samples[0]))
    }

    private static func hasReachedMilestoneTwoEnd(
        journey: SkincareJourney,
        on date: Date,
        calendar: Calendar = .current
    ) -> Bool {
        guard let milestoneOneEndDate = journey.milestones.first(where: { $0.order == 1 })?.completedDate,
              let targetDate = calendar.date(
                byAdding: .day,
                value: MilestoneProgress.flagDurationDays * 4,
                to: milestoneOneEndDate
              ) else {
            return false
        }

        return calendar.startOfDay(for: date) >= calendar.startOfDay(for: targetDate)
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
    case personalization
    case chooseProduct(imageName: String?)
    case selectedProduct(product: SkincareProduct, imageName: String?)
    case mainJourney
    case journeyDetail(journeyID: UUID? = nil, hideProgressBar: Bool = false, initialIndex: Int? = nil)
    case historyJournaling
    case calendarJournaling
    case camera
    case selfAssessment(imageName: String?)
    case journalEntry(imageName: String?, skinCondition: String, howItFeels: String, whatYouNoticed: String)
    case milestoneOneCompletion
    case milestoneTwoCompletion
    case productValidation
}


#Preview {
    SkinJournalRootView()
}
