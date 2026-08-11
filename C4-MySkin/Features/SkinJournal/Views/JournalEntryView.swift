//
//  JournalEntryView.swift
//  C4-MySkin
//

import SwiftUI

struct JournalEntryView: View {
    @State private var viewModel = JournalEntryViewModel()
    let milestoneTitle: String?
    let onSave: (JournalEntry) -> Void
    let onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                faceSection
                tagSection
                noteSection
                saveButton
            }
            .padding(.horizontal, 20)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(milestoneTitle ?? "Journal Entry")
                .font(.title2.weight(.bold))

            Text(dateString(viewModel.date))
                .font(.body.weight(.medium))
                .foregroundStyle(Color(.secondaryLabel))

            HStack(spacing: 24) {
                ForEach(0..<5) { index in
                    Image(systemName: index < 3 ? "circle.fill" : "circle")
                        .font(.caption2)
                        .foregroundStyle(Color(.secondaryLabel))
                }
            }
            .padding(.top, 8)
        }
        .padding(.top, 16)
    }

    private var faceSection: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.secondarySystemBackground))
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                FaceOutline()
                    .frame(width: 180, height: 240)
            )
    }

    private var tagSection: some View {
        HStack(spacing: 8) {
            ForEach(QuickTag.allCases) { tag in
                Button(action: { viewModel.toggleTag(tag) }) {
                    Text(tag.rawValue)
                        .font(.caption.weight(viewModel.selectedTags.contains(tag) ? .semibold : .regular))
                        .foregroundStyle(viewModel.selectedTags.contains(tag) ? Color(.systemBackground) : Color(.label))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedTags.contains(tag) ? Color(.label) : Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How's your skin today?")
                .font(.headline.weight(.semibold))

            TextEditor(text: $viewModel.note)
                .font(.body)
                .frame(minHeight: 120)
                .padding(8)
                .background(
                    linedPaper
                )
        }
    }

    private var linedPaper: some View {
        VStack(spacing: 20) {
            ForEach(0..<6) { _ in
                Divider()
                    .background(Color(.separator))
            }
        }
        .padding(.top, 8)
        .background(Color(.systemBackground))
    }

    private var saveButton: some View {
        Button(action: {
            onSave(viewModel.createEntry())
        }) {
            Text("Save")
                .font(.body.weight(.semibold))
                .foregroundStyle(viewModel.canSave ? Color(.label) : Color(.secondaryLabel))
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(viewModel.canSave ? Color(.secondarySystemBackground) : Color(.tertiarySystemBackground))
                .clipShape(Capsule())
        }
        .disabled(!viewModel.canSave)
        .buttonStyle(.plain)
        .padding(.bottom, 32)
    }

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    JournalEntryView(milestoneTitle: "Milestone 2", onSave: { _ in }, onBack: {})
}
