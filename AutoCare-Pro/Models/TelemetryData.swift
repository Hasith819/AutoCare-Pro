//
//  TelemetryData.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-27.
//

import Foundation

enum ConnectionState {
    case disconnected
    case connectingBLE
    case bleConnected
    case ecuConnecting
    case ecuConnected
    case error(String)
}

struct DTCCode: Identifiable, Hashable {
    let code: String
    let category: String

    var id: String {
        "\(category)-\(code)"
    }

    var description: String {
        switch code {
        case "P0300": return "Random / Multiple Cylinder Misfire"
        case "P0301": return "Cylinder 1 Misfire"
        case "P0302": return "Cylinder 2 Misfire"
        case "P0303": return "Cylinder 3 Misfire"
        case "P0304": return "Cylinder 4 Misfire"
        case "P0171": return "System Too Lean"
        case "P0172": return "System Too Rich"
        case "P0420": return "Catalyst Efficiency Below Threshold"
        case "P0128": return "Coolant Thermostat Temperature Below Range"
        default: return "Diagnostic trouble code detected"
        }
    }
}

struct TelemetryData {
    var state: ConnectionState = .disconnected
    var statusMessage = "Disconnected"

    var speedKmh = 0
    var rpm = 0
    var coolantTempC = 0

    var batteryVoltage: Double?
    var tripDistanceKm: Double = 0
    var distanceSinceCodesClearedKm: Double?

    var storedCodes: [DTCCode] = []
    var pendingCodes: [DTCCode] = []
    var permanentCodes: [DTCCode] = []

    var isScanningDTCs = false
    var hasCompletedDTCScan = false
    var dtcScanMessage = "No diagnostic scan performed"

    var ecuErrorReason: String?
}
