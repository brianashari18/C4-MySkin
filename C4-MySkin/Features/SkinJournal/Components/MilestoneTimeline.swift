//
//  MilestoneTimeline.swift
//  C4-MySkin
//

import SwiftUI

struct MilestoneTimeline: View {
    let milestones: [Milestone]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(milestones.enumerated()), id: \.element.id) { index, milestone in
                milestoneNode(milestone)

                if index < milestones.count - 1 {
                    connectingLine(isActive: milestone.isCompleted)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func milestoneNode(_ milestone: Milestone) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(nodeFill(for: milestone))
                    .frame(width: 44, height: 44)

                Image(systemName: nodeIcon(for: milestone))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(nodeForeground(for: milestone))
            }

            if let date = milestone.completedDate {
                Text(dateString(date))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func connectingLine(isActive: Bool) -> some View {
        Rectangle()
            .fill(isActive ? Color(.label) : Color(.separator))
            .frame(height: 2)
            .frame(maxWidth: .infinity)
    }

    private func nodeFill(for milestone: Milestone) -> Color {
        milestone.isCompleted ? Color(.label) : Color(.secondarySystemBackground)
    }

    private func nodeForeground(for milestone: Milestone) -> Color {
        milestone.isCompleted ? Color(.systemBackground) : Color(.secondaryLabel)
    }

    private func nodeIcon(for milestone: Milestone) -> String {
        switch milestone.order {
        case 1: return "jar.fill"
        case 2: return "face.smiling.fill"
        default: return "flag.fill"
        }
    }

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d/M yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    MilestoneTimeline(milestones: Milestone.defaultMilestones)
        .padding()
}
