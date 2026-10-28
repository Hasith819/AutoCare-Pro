//
//  TelemetryView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//
import SwiftUI

struct TelemetryView: View {

    @StateObject private var viewModel = OBDViewModel()

    private var telemetry: TelemetryData {
        viewModel.telemetry
    }

    private var batteryText: String {
        guard let voltage = telemetry.batteryVoltage else {
            return "--"
        }

        return String(format: "%.1f V", voltage)
    }

    private var tripText: String {
        String(format: "%.2f km", telemetry.tripDistanceKm)
    }

    private var allDiagnosticCodes: [DTCCode] {
        telemetry.storedCodes
        + telemetry.pendingCodes
        + telemetry.permanentCodes
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // Fixed header
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 16)
                    .background(AppColors.background)

                // Scrollable telemetry content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        connectionSection
                        speedSection
                        metricsSection
                        diagnosticSection

                        if let reason = telemetry.ecuErrorReason {
                            errorSection(reason)
                        }

                        Spacer()
                            .frame(height: 30)
                    }
                    .padding(20)
                    .padding(.top, 0)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Live Telemetry")
                .font(AppFonts.title2)
                .foregroundStyle(AppColors.primaryText)

            Text("Monitor your vehicle's live engine data.")
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var connectionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Circle()
                    .fill(viewModel.connectionColor)
                    .frame(width: 10, height: 10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.connectionLabel)
                        .font(.headline)
                        .foregroundStyle(AppColors.primaryText)

                    Text(telemetry.statusMessage)
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }

                Spacer(minLength: 8)
            }

            Button {
                viewModel.toggleConnection()
            } label: {
                HStack(spacing: 8) {
                    Image(
                        systemName: viewModel.isBLEActive
                            ? "xmark.circle"
                            : "dot.radiowaves.left.and.right"
                    )

                    Text(viewModel.connectionButtonTitle)
                }
                .font(.headline)
                .foregroundStyle(AppColors.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColors.buttonBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            AppColors.accent.opacity(0.45),
                            lineWidth: 1
                        )
                }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var speedSection: some View {
        VStack(spacing: 14) {
            Text("VEHICLE SPEED")
                .font(.caption)
                .fontWeight(.semibold)
                .tracking(2)
                .foregroundStyle(AppColors.secondaryLabel)

            ZStack {
                Circle()
                    .stroke(
                        AppColors.secondaryLabel.opacity(0.2),
                        lineWidth: 12
                    )

                Circle()
                    .trim(
                        from: 0,
                        to: min(
                            CGFloat(telemetry.speedKmh) / 180,
                            1
                        )
                    )
                    .stroke(
                        AppColors.accent,
                        style: StrokeStyle(
                            lineWidth: 12,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(telemetry.speedKmh)")
                        .font(
                            .system(
                                size: 52,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(AppColors.primaryText)
                        .contentTransition(.numericText())

                    Text("km/h")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
            .frame(width: 210, height: 210)
            .padding(.vertical, 8)

            Text(
                viewModel.isECUActive
                    ? "Receiving vehicle data"
                    : "Waiting for ECU connection"
            )
            .font(.caption)
            .foregroundStyle(AppColors.secondaryLabel)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Engine Metrics")

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                StatCard(
                    title: "ENGINE RPM",
                    value: viewModel.isECUActive
                        ? "\(telemetry.rpm)"
                        : "--",
                    subtitle: "Engine speed"
                )

                StatCard(
                    title: "COOLANT TEMP",
                    value: viewModel.isECUActive
                        ? "\(telemetry.coolantTempC) °C"
                        : "--",
                    subtitle: "Engine coolant temperature",
                    valueColor: coolantColor
                )

                StatCard(
                    title: "BATTERY VOLTAGE",
                    value: viewModel.isECUActive ? batteryText : "--",
                    subtitle: "Voltage reported by ECU or adapter"
                )

                StatCard(
                    title: "TRIP DISTANCE",
                    value: tripText,
                    subtitle: "Estimated while connected"
                )
            }
        }
    }

    private var coolantColor: Color {
        guard viewModel.isECUActive else {
            return AppColors.accent
        }

        if telemetry.coolantTempC >= 110 {
            return .red
        }

        if telemetry.coolantTempC >= 100 {
            return .orange
        }

        return AppColors.accent
    }

    private var diagnosticSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            scannerHeaderSection

            if telemetry.isScanningDTCs {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(AppColors.accent)

                    Text("Reading diagnostic trouble codes...")
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(AppColors.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            } else if telemetry.hasCompletedDTCScan {
                dtcCodesSection

            } else {
                Text(telemetry.dtcScanMessage)
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(AppColors.inputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private var scannerHeaderSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)

            Text("DTC Fault Diagnostic Scanner")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(2)

            Spacer(minLength: 4)

            Button {
                viewModel.scanFaultCodes()
            } label: {
                HStack(spacing: 6) {
                    if telemetry.isScanningDTCs {
                        ProgressView()
                            .tint(AppColors.accent)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }

                    Text(
                        telemetry.isScanningDTCs
                            ? "Scanning..."
                            : "Deep Scan"
                    )
                }
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.accent)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(AppColors.buttonBackground)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(
                !viewModel.isECUActive
                || telemetry.isScanningDTCs
            )
            .opacity(viewModel.isECUActive ? 1 : 0.5)
        }
    }

    @ViewBuilder
    private var dtcCodesSection: some View {
        if allDiagnosticCodes.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Label(
                    "No codes reported",
                    systemImage: "checkmark.circle.fill"
                )
                .font(.subheadline.bold())
                .foregroundStyle(.green)

                Text(telemetry.dtcScanMessage)
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryLabel)

                Text(
                    "This means the ECU reported no codes in the scanned categories. It does not guarantee that every vehicle system is fault-free."
                )
                .font(.caption2)
                .foregroundStyle(AppColors.secondaryLabel)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(AppColors.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))

        } else {
            VStack(spacing: 14) {
                ForEach(
                    Array(allDiagnosticCodes.enumerated()),
                    id: \.offset
                ) { _, code in
                    dtcCard(code)
                }
            }
        }
    }

    private func dtcCard(_ code: DTCCode) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Diagnostic Trouble Code")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.primaryText)

                Spacer()

                Text(code.category)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(statusColor(for: code))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor(for: code).opacity(0.15))
                    .clipShape(Capsule())
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(code.code)
                    .font(.headline.bold())
                    .foregroundStyle(AppColors.accent)

                Text(code.description)
                    .font(.caption)
                    .foregroundStyle(AppColors.primaryText)
            }

            Text("Severity: Warning")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(statusColor(for: code))

            Text("Reported by the vehicle ECU during this scan.")
                .font(.caption2)
                .foregroundStyle(AppColors.secondaryLabel)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    statusColor(for: code).opacity(0.7),
                    lineWidth: 1.5
                )
        }
    }

    private func statusColor(for code: DTCCode) -> Color {
        switch code.category {
        case "Permanent":
            return .red

        case "Pending":
            return .orange

        default:
            return .orange
        }
    }

    private func errorSection(_ reason: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(
                "Connection Details",
                systemImage: "exclamationmark.triangle"
            )
            .font(.headline)
            .foregroundStyle(.orange)

            Text(reason)
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3.bold())
            .foregroundStyle(AppColors.primaryText)
    }
}

#Preview {
    NavigationStack {
        TelemetryView()
    }
}
