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

    @State private var currentMonthDate = Date()
    private let calendar = Calendar.current

    init(
        journey: SkincareJourney,
        onSelectDateEntry: @escaping (JournalEntry, Int) -> Void = { _, _ in }
    ) {
        self.journey = journey
        self.onSelectDateEntry = onSelectDateEntry
    }

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonthDate) else { return [] }
        let firstDayOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) // 1 = Sun, 2 = Mon...

        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)

        let numberOfDays = calendar.range(of: .day, in: .month, for: currentMonthDate)?.count ?? 30
        for day in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        return days
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
                .padding(.top, 50)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Month Navigation Header Card
                        HStack {
                            Button(action: {
                                changeMonth(by: -1)
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                                    .frame(width: 36, height: 36)
                                    .background(Circle().fill(Color.white))
                            }

                            Spacer()

                            Text(monthYearString(from: currentMonthDate))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))

                            Spacer()

                            Button(action: {
                                changeMonth(by: 1)
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                                    .frame(width: 36, height: 36)
                                    .background(Circle().fill(Color.white))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.4), lineWidth: 1.5)
                        )
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        // Main Calendar Card Box
                        VStack(spacing: 16) {
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
                            .padding(.bottom, 4)

                            // Days Grid
                            let columns = Array(repeating: GridItem(.flexible()), count: 7)
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(0..<daysInMonth.count, id: \.self) { index in
                                    if let date = daysInMonth[index] {
                                        DayCell(
                                            date: date,
                                            entries: sampleEntries,
                                            onTap: { entry, entryIndex in
                                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                                generator.impactOccurred()
                                                onSelectDateEntry(entry, entryIndex)
                                            }
                                        )
                                    } else {
                                        Color.clear.frame(height: 44)
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
                        .padding(.horizontal, 24)

                        // Legend hint card
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color(red: 0.38, green: 0.61, blue: 0.93))
                                .frame(width: 10, height: 10)

                            Text("Tanggal dengan foto progress/jurnal (klik untuk melihat foto hari itu)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))

                            Spacer()
                        }
                        .padding(14)
                        .background(Color(red: 0.92, green: 0.96, blue: 1.0))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentMonthDate) {
            currentMonthDate = newDate
        }
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Individual Calendar Day Cell Component
private struct DayCell: View {
    let date: Date
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
            VStack(spacing: 4) {
                Text("\(dayNumber)")
                    .font(.system(size: 15, weight: isToday ? .black : (hasEntry ? .bold : .medium)))
                    .foregroundStyle(
                        hasEntry
                            ? Color.white
                            : (isToday ? Color(red: 0.38, green: 0.61, blue: 0.93) : Color(red: 0.16, green: 0.35, blue: 0.54))
                    )

                if hasEntry {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.white)
                }
            }
            .frame(width: 38, height: 42)
            .background(
                Group {
                    if hasEntry {
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
        .disabled(!hasEntry)
    }
}

#Preview {
    SkinJournalCalendarView(journey: SkincareJourney(product: SkincareProduct.samples[0]))
}
