//
//  StatCard.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//



import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    var valueColor: Color = AppColors.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(AppColors.secondaryLabel)
                .lineLimit(1)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .contentTransition(.numericText())

            // Subtitle is displayed only when supplied.
            Group {
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 9))
                        .foregroundStyle(AppColors.secondaryLabel)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                } else {
                    Text(" ")
                        .font(.system(size: 9))
                }
            }
            .frame(height: 24, alignment: .topLeading)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 60, alignment: .topLeading)
        .padding(14)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HStack(spacing: 12) {
        StatCard(
            title: "ODOMETER",
            value: "128,642 km",
            subtitle: "Next service • 132,000 km"
        )

        StatCard(
            title: "OBD STATUS",
            value: "Connected",
            valueColor: .green
        )
    }
    .padding()
    .background(AppColors.background)
}
