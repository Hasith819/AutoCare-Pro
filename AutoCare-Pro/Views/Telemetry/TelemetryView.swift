//
//  TelemetryView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//

import SwiftUI

struct TelemetryView: View {
    @State private var speed: Int = 64
    @State private var rpm: Int = 3450
    @State private var tripToday: String = "12.4 km"
    @State private var coolantTemp: String = "91 °C"
    @State private var batteryVoltage: String = "13.9 V"
    @State private var protocolName: String = "OBD-II"
    @State private var isConnected: Bool = true
    @State private var isScanning: Bool = false

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                
                    headerSection
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                  
                    speedGaugeSection
                        .padding(.horizontal, 20)

             
                    metricsGridSection
                        .padding(.horizontal, 20)

              
                    scannerHeaderSection
                        .padding(.horizontal, 20)

             
                    dtcCodesSection
                        .padding(.horizontal, 20)

                    Spacer().frame(height: 30)
                }
                .padding(.vertical, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }

   

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Live Telemetry")
                    .font(AppFonts.heading)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.primaryText)

                Text("ELM327 • CoreBluetooth • ECU stream")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.secondaryLabel)
            }

            Spacer()

         
            HStack(spacing: 6) {
                Circle()
                    .fill(isConnected ? Color.green : Color.red)
                    .frame(width: 8, height: 8)

                Text(isConnected ? "Connected" : "Disconnected")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(isConnected ? Color.green : Color.red)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.15))
            .clipShape(Capsule())
        }
    }

    private var speedGaugeSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.inputBackground)

            VStack(spacing: 16) {
               
                ZStack {
                    Circle()
                        .stroke(AppColors.secondaryLabel.opacity(0.2), lineWidth: 6)
                        .frame(width: 150, height: 150)

                    Circle()
                        .trim(from: 0.0, to: 0.75)
                        .stroke(AppColors.accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(135))

                    VStack(spacing: 2) {
                        Text("\(speed)")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.primaryText)

                        Text("km/h")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.accent)

                        Text("\(rpm) rpm")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                            .padding(.top, 2)
                    }
                }
                .padding(.vertical, 20)
            }
        }
    }

    private var metricsGridSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            metricCard(title: "Trip Today", value: tripToday, color: AppColors.accent)
            metricCard(title: "Coolant Temp", value: coolantTemp, color: .green)
            metricCard(title: "Battery", value: batteryVoltage, color: AppColors.accent)
            metricCard(title: "Protocol", value: protocolName, color: AppColors.primaryText)
        }
    }

    private func metricCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFonts.footer)
                .foregroundStyle(AppColors.secondaryLabel)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var scannerHeaderSection: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)

                Text("DTC Fault Diagnostic Scanner")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.primaryText)
            }

            Spacer()

            Button {
                isScanning = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isScanning = false
                }
            } label: {
                HStack(spacing: 6) {
                    if isScanning {
                        ProgressView()
                            .tint(AppColors.accent)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text("Deep Scan")
                }
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.accent)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(AppColors.buttonBackground)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var dtcCodesSection: some View {
        VStack(spacing: 14) {
            // Warning DTC Card (Red Outline)
            dtcCard(
                title: "Diagnostic Trouble Codes",
                code: "P0300",
                description: "Random / Multiple Cylinder Misfire",
                severity: "Severity: Warning",
                details: "Engine detected irregular combustion.",
                statusText: "Warning",
                statusColor: .orange,
                borderColor: .red
            )

       
            dtcCard(
                title: "Diagnostic Trouble Codes",
                code: "P0300",
                description: "Random / Multiple Cylinder Misfire",
                severity: "Severity: Warning",
                details: "Engine detected irregular combustion.",
                statusText: "Resolved",
                statusColor: .green,
                borderColor: .green
            )
        }
    }

    private func dtcCard(
        title: String,
        code: String,
        description: String,
        severity: String,
        details: String,
        statusText: String,
        statusColor: Color,
        borderColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.primaryText)

                Spacer()

                Text(statusText)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(code)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.accent)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(AppColors.primaryText)
            }

            Text(severity)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(statusColor)

            Text(details)
                .font(.caption2)
                .foregroundStyle(AppColors.secondaryLabel)
        }
        .padding(16)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor.opacity(0.7), lineWidth: 1.5)
        )
    }
}

#Preview {
    NavigationStack {
        TelemetryView()
    }
}
