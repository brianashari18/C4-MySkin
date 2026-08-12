//
//  SkinJournalCalendarView.swift
//  C4-MySkin
//

import SwiftUI

/// Layar Kalender Jurnal Skincare — menampilkan tampilan bulan kalender
/// dengan penanda tanggal untuk foto progress/jurnal yang telah di-upload.
/// Mengeklik tanggal yang berfoto akan membuka JourneyDetailView tanpa progress bar.
struct SkinJournalCalendarView: View {
    @Environment(\.dismiss) private var dismiss
    let journey: SkincareJourney
    let onSelectDateEntry: (JournalEntry, Int) -> Void

    private let calendar = Calendar.current

    init(
        journey: SkincareJourney,
        onSelectDateEntry: @escaping (JournalEntry, Int) -> Void = { _, _ in }
    ) {
        self.journey = journey
        self.onSelectDateEntry = onSelectDateEntry
    }

    /// Daftar 12 bulan terakhir untuk vertical scroll (Instagram archive style)
    private var availableMonths: [Date] {
        (0..<12).compactMap { offset in
            calendar.date(byAdding: .month, value: -offset, to: Date())
        }
    }

    private var sampleEntries: [JournalEntry] {
        if !journey.journalEntries.isEmpty {
            return journey.journalEntries
        }
        return [
            JournalEntry(date: Date(), note: "hari ini kulitku kayak gemoy gitu, suka!!", skinCondition: "Slightly Better", howItFeels: "Feels comfortable", whatYouNoticed: "Dryness")
        ]
    }

    var body: some View {
        ZStack {
            // Soft ice blue background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.94, green: 0.97, blue: 1.0),
                    Color(red: 0.90, green: 0.95, blue: 0.99)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Bar Header with Back Button & Title
                VStack(spacing: 12) {
                    HStack {
                        BackButton {
                            dismiss()
                        }
                        Spacer()
                    }

                    Text("Journal Calendar")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                }
                .padding(.horizontal, 24)

                // Vertical Scrollable Months (Instagram Archive Style)
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(availableMonths, id: \.self) { monthDate in
                            MonthCalendarCard(
                                monthDate: monthDate,
                                journey: journey,
                                entries: sampleEntries,
                                onSelectDateEntry: onSelectDateEntry
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Month Calendar Card (Instagram Archive Section)
private struct MonthCalendarCard: View {
    let monthDate: Date
    let journey: SkincareJourney
    let entries: [JournalEntry]
    let onSelectDateEntry: (JournalEntry, Int) -> Void

    private let calendar = Calendar.current

    private var monthYearTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: monthDate)
    }

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else { return [] }
        let firstDayOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) // 1 = Sun, 2 = Mon...

        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)

        let numberOfDays = calendar.range(of: .day, in: .month, for: monthDate)?.count ?? 30
        for day in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        return days
    }

    var body: some View {
        VStack(spacing: 16) {
            // Month Header Title (No left/right arrow buttons)
            Text(monthYearTitle)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 4)

            // Weekday headers
            let weekdays = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"]
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                        .frame(maxWidth: .infinity)
                }
            }

            // Days Grid
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<daysInMonth.count, id: \.self) { index in
                    if let date = daysInMonth[index] {
                        DayCell(
                            date: date,
                            journey: journey,
                            entries: entries,
                            onTap: { entry, entryIndex in
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                onSelectDateEntry(entry, entryIndex)
                            }
                        )
                    } else {
                        Color.clear.frame(height: 42)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(red: 0.38, green: 0.61, blue: 0.93), lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Individual Calendar Day Cell Component
private struct DayCell: View {
    let date: Date
    let journey: SkincareJourney
    let entries: [JournalEntry]
    let onTap: (JournalEntry, Int) -> Void

    private let calendar = Calendar.current

    private var entryForDate: (JournalEntry, Int)? {
        for (index, entry) in entries.enumerated() {
            if calendar.isDate(entry.date, inSameDayAs: date) {
                return (entry, index)
            }
        }
        // Fallback demo highlight for 4th or 12th day if sample
        let dayNum = calendar.component(.day, from: date)
        if (dayNum == 4 || dayNum == 12) && !entries.isEmpty {
            return (entries.first!, 0)
        }
        return nil
    }

    private var photoImage: UIImage? {
        if let photo = journey.progressPhotos.first(where: { calendar.isDate($0.date, inSameDayAs: date) }),
           let image = CameraViewModel.loadImage(named: photo.imageName) {
            return image
        }
        if let entry = journey.journalEntries.first(where: { calendar.isDate($0.date, inSameDayAs: date) && $0.imageName != nil }),
           let imageName = entry.imageName,
           let image = CameraViewModel.loadImage(named: imageName) {
            return image
        }
        return nil
    }

    private var isToday: Bool {
        calendar.isDateInToday(date)
    }

    var body: some View {
        let dayNumber = calendar.component(.day, from: date)
        let hasEntry = entryForDate != nil

        Button(action: {
            if let (entry, index) = entryForDate {
                onTap(entry, index)
            }
        }) {
            ZStack {
                if let photoImage {
                    Image(uiImage: photoImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 38, height: 42)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.15))
                        )
                }

                Text("\(dayNumber)")
                    .font(.system(size: 15, weight: isToday ? .black : ((hasEntry || photoImage != nil) ? .bold : .medium)))
                    .foregroundStyle(
                        (hasEntry || photoImage != nil)
                            ? Color.white
                            : (isToday ? Color(red: 0.38, green: 0.61, blue: 0.93) : Color(red: 0.16, green: 0.35, blue: 0.54))
                    )
                    .shadow(color: photoImage != nil ? Color.black.opacity(0.6) : Color.clear, radius: 2, x: 0, y: 1)
            }
            .frame(width: 38, height: 42)
            .background(
                Group {
                    if photoImage != nil {
                        Color.clear
                    } else if hasEntry {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.38, green: 0.61, blue: 0.93))
                    } else if isToday {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.38, green: 0.61, blue: 0.93), lineWidth: 2)
                    } else {
                        Color.clear
                    }
                }
            )
        }
        .buttonStyle(.plain)
        .disabled(!hasEntry && photoImage == nil)
    }
}

#Preview {
    SkinJournalCalendarView(journey: SkincareJourney(product: SkincareProduct.samples[0]))
}
