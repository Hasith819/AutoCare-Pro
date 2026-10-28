//
//  VehicleDropdownView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-28.
//


import SwiftUI

struct VehicleDropdownView: View {
    let vehicles: [Vehicle]
    let selectedVehicleID: UUID?
    let onSelect: (Vehicle) -> Void
    let onEdit: (Vehicle) -> Void
    let onDelete: (Vehicle) -> Void

    var body: some View {
        VStack(spacing: 0) {
            if vehicles.isEmpty {
                Text("No vehicles added yet.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            } else {
                ForEach(vehicles) { vehicle in
                    HStack(spacing: 10) {
                        Button {
                            onSelect(vehicle)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "car.side.fill")
                                    .font(.title3)
                                    .foregroundStyle(AppColors.accent)
                                    .frame(width: 38, height: 38)
                                    .background(AppColors.buttonBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(vehicle.brand) \(vehicle.model)")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppColors.primaryText)

                                    Text(vehicle.registrationNumber)
                                        .font(.caption)
                                        .foregroundStyle(AppColors.secondaryLabel)
                                }

                                Spacer(minLength: 0)

                                if vehicle.id == selectedVehicleID {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(AppColors.accent)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Button {
                            onEdit(vehicle)
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppColors.accent)
                                .frame(width: 34, height: 34)
                                .background(AppColors.buttonBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 9))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Edit \(vehicle.brand) \(vehicle.model)")

                        Button {
                            onDelete(vehicle)
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.red)
                                .frame(width: 34, height: 34)
                                .background(Color.red.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 9))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Delete \(vehicle.brand) \(vehicle.model)")
                    }
                    .padding(12)

                    if vehicle.id != vehicles.last?.id {
                        Divider()
                            .overlay(AppColors.secondaryLabel.opacity(0.15))
                            .padding(.leading, 12)
                    }
                }
            }
        }
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
