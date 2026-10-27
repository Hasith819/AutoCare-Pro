//
//  OBDViewModel.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-27.
//
import Foundation
import Combine
import SwiftUI

final class OBDViewModel: ObservableObject, BLEOBDServiceDelegate {

    @Published var telemetry = TelemetryData()

    private let bleService: BLEOBDService

    init(bleService: BLEOBDService = BLEOBDService()) {
        self.bleService = bleService
        self.bleService.delegate = self
    }

    func toggleConnection() {
        switch telemetry.state {
        case .disconnected, .error:
            bleService.startScanning()

        default:
            bleService.disconnect()
        }
    }

    func scanFaultCodes() {
        bleService.scanFaultCodes()
    }

    func didUpdateTelemetry(_ data: TelemetryData) {
        DispatchQueue.main.async {
            self.telemetry = data
        }
    }

    var isBLEActive: Bool {
        switch telemetry.state {
        case .bleConnected, .ecuConnecting, .ecuConnected:
            return true

        default:
            return false
        }
    }

    var isECUActive: Bool {
        if case .ecuConnected = telemetry.state {
            return true
        }

        return false
    }

    var connectionLabel: String {
        switch telemetry.state {
        case .disconnected:
            return "Disconnected"

        case .connectingBLE:
            return "Searching for adapter"

        case .bleConnected:
            return "Bluetooth connected"

        case .ecuConnecting:
            return "Connecting to ECU"

        case .ecuConnected:
            return "ECU ready"

        case .error:
            return "Connection error"
        }
    }

    var connectionColor: Color {
        switch telemetry.state {
        case .ecuConnected:
            return .green

        case .connectingBLE, .bleConnected, .ecuConnecting:
            return .orange

        case .disconnected, .error:
            return .red
        }
    }

    var connectionButtonTitle: String {
        switch telemetry.state {
        case .disconnected, .error:
            return "Connect OBD-II"

        default:
            return "Disconnect OBD-II"
        }
    }
}
