//
//  BLEOBDService.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-27.
//

import Foundation
import CoreBluetooth
import Combine

protocol BLEOBDServiceDelegate: AnyObject {
    func didUpdateTelemetry(_ data: TelemetryData)
}

private enum OBDCommandPurpose {
    case initialization
    case speed
    case rpm
    case coolant
    case distance
    case battery
    case adapterVoltage
    case storedDTC
    case pendingDTC
    case permanentDTC
}

private struct OBDCommand {
    let text: String
    let purpose: OBDCommandPurpose
}

final class BLEOBDService: NSObject,
                           CBCentralManagerDelegate,
                           CBPeripheralDelegate {

    weak var delegate: BLEOBDServiceDelegate?

    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?

    private var txCharacteristic: CBCharacteristic?
    private var rxCharacteristic: CBCharacteristic?

    private var telemetry = TelemetryData()

    private var commandQueue: [OBDCommand] = []
    private var currentCommand: OBDCommand?
    private var responseBuffer = ""

    private var isInitializingECU = false
    private var isPolling = false
    private var isScanningDTCs = false
    private var completedDTCResponses = 0

    private var lastSpeedUpdate: Date?
    private var pollingIndex = 0

    private let pollingCommands: [OBDCommand] = [
        OBDCommand(text: "010D", purpose: .speed),
        OBDCommand(text: "010C", purpose: .rpm),
        OBDCommand(text: "0105", purpose: .coolant),
        OBDCommand(text: "0131", purpose: .distance),
        OBDCommand(text: "0142", purpose: .battery),
        OBDCommand(text: "ATRV", purpose: .adapterVoltage)
    ]

    override init() {
        super.init()
        centralManager = CBCentralManager(
            delegate: self,
            queue: .main
        )
    }

    // MARK: - Public methods

    func startScanning() {
        guard centralManager.state == .poweredOn else {
            telemetry.state = .error("Bluetooth is unavailable")
            telemetry.statusMessage =
                "Turn on Bluetooth and allow Bluetooth access."
            publish()
            return
        }

        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            connectedPeripheral = nil
            txCharacteristic = nil
            rxCharacteristic = nil
        }

        commandQueue.removeAll()
        currentCommand = nil
        responseBuffer = ""

        isInitializingECU = false
        isPolling = false
        isScanningDTCs = false

        telemetry = TelemetryData()
        telemetry.state = .connectingBLE
        telemetry.statusMessage = "Searching for OBD-II adapter"

        // Start a new estimated trip for this connection attempt.
        telemetry.tripDistanceKm = 0
        telemetry.batteryVoltage = nil
        telemetry.distanceSinceCodesClearedKm = nil

        lastSpeedUpdate = nil
        pollingIndex = 0

        publish()

        centralManager.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
    }

    func disconnect() {
        centralManager.stopScan()

        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }

        resetConnection()
    }

    func scanFaultCodes() {
        guard case .ecuConnected = telemetry.state else {
            telemetry.dtcScanMessage =
                "Connect to the vehicle ECU before scanning."
            publish()
            return
        }

        guard !isScanningDTCs else {
            return
        }

        isScanningDTCs = true
        completedDTCResponses = 0

        telemetry.isScanningDTCs = true
        telemetry.hasCompletedDTCScan = false
        telemetry.dtcScanMessage = "Scanning diagnostic trouble codes..."

        telemetry.storedCodes = []
        telemetry.pendingCodes = []
        telemetry.permanentCodes = []

        publish()

        // These are read-only diagnostic requests.
        commandQueue.append(
            OBDCommand(text: "03", purpose: .storedDTC)
        )
        commandQueue.append(
            OBDCommand(text: "07", purpose: .pendingDTC)
        )
        commandQueue.append(
            OBDCommand(text: "0A", purpose: .permanentDTC)
        )

        processNextCommand()
    }

    // MARK: - Bluetooth state

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            telemetry.state = .error("Bluetooth unavailable")
            telemetry.statusMessage = "Enable Bluetooth on your iPhone."
            publish()
            return
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let advertisedName =
            (peripheral.name
             ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String
             ?? "").lowercased()

        let supportedName =
            advertisedName.contains("elm")
            || advertisedName.contains("obd")
            || advertisedName.contains("v-link")
            || advertisedName.contains("vlink")
            || advertisedName.contains("ble")

        guard supportedName else {
            return
        }

        central.stopScan()

        connectedPeripheral = peripheral
        peripheral.delegate = self

        telemetry.state = .connectingBLE
        telemetry.statusMessage = "Connecting to \(peripheral.name ?? "OBD adapter")"
        publish()

        central.connect(peripheral, options: nil)
    }

    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        connectedPeripheral = peripheral
        peripheral.delegate = self

        telemetry.state = .bleConnected
        telemetry.statusMessage = "Bluetooth connected. Finding adapter services..."
        publish()

        peripheral.discoverServices(nil)
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        failConnection(
            message: "Could not connect to the OBD adapter.",
            reason: error?.localizedDescription
                ?? "Check that the adapter is powered on and in range."
        )
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        if case .error = telemetry.state {
            publish()
            return
        }

        resetConnection()
    }

    // MARK: - Peripheral services

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        if let error {
            failConnection(
                message: "Could not discover adapter services.",
                reason: error.localizedDescription
            )
            return
        }

        guard let services = peripheral.services, !services.isEmpty else {
            failConnection(
                message: "No Bluetooth services found.",
                reason: "This adapter may not be compatible with BLE."
            )
            return
        }

        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        if let error {
            failConnection(
                message: "Could not discover adapter characteristics.",
                reason: error.localizedDescription
            )
            return
        }

        guard let characteristics = service.characteristics else {
            return
        }

        for characteristic in characteristics {
            let properties = characteristic.properties

            if properties.contains(.write)
                || properties.contains(.writeWithoutResponse) {
                txCharacteristic = characteristic
            }

            if properties.contains(.notify)
                || properties.contains(.indicate) {
                rxCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }

        startInitializationIfReady()
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error {
            failConnection(
                message: "Could not enable adapter notifications.",
                reason: error.localizedDescription
            )
            return
        }

        startInitializationIfReady()
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error {
            failConnection(
                message: "Could not read adapter response.",
                reason: error.localizedDescription
            )
            return
        }

        guard let data = characteristic.value,
              let text = String(data: data, encoding: .utf8) else {
            return
        }

        responseBuffer += text

        // ELM adapters normally finish a response with ">".
        if responseBuffer.contains(">") {
            let response = responseBuffer
            responseBuffer = ""
            handleResponse(response)
        }
    }

    // MARK: - ELM initialization

    private func startInitializationIfReady() {
        guard let peripheral = connectedPeripheral,
              txCharacteristic != nil,
              rxCharacteristic != nil,
              !isInitializingECU,
              !isPolling else {
            return
        }

        // Wait until the notification subscription is active.
        guard let rx = rxCharacteristic, rx.isNotifying else {
            return
        }

        isInitializingECU = true

        telemetry.state = .ecuConnecting
        telemetry.statusMessage = "Initializing OBD-II adapter..."
        publish()

        commandQueue = [
            OBDCommand(text: "ATZ", purpose: .initialization),
            OBDCommand(text: "ATE0", purpose: .initialization),
            OBDCommand(text: "ATL0", purpose: .initialization),
            OBDCommand(text: "ATS0", purpose: .initialization),
            OBDCommand(text: "ATH0", purpose: .initialization),
            OBDCommand(text: "ATSP0", purpose: .initialization),
            OBDCommand(text: "0100", purpose: .initialization)
        ]

        currentCommand = nil
        responseBuffer = ""

        // Keep the reference alive through the queued command process.
        _ = peripheral
        processNextCommand()
    }

    // MARK: - Command queue

    private func processNextCommand() {
        guard currentCommand == nil else {
            return
        }

        guard !commandQueue.isEmpty else {
            handleQueueFinished()
            return
        }

        guard let peripheral = connectedPeripheral,
              let characteristic = txCharacteristic else {
            return
        }

        let command = commandQueue.removeFirst()
        currentCommand = command
        responseBuffer = ""

        guard let data = (command.text + "\r").data(using: .utf8) else {
            failConnection(
                message: "Could not prepare OBD command.",
                reason: "The command could not be encoded."
            )
            return
        }

        let properties = characteristic.properties

        if properties.contains(.write) {
            peripheral.writeValue(
                data,
                for: characteristic,
                type: .withResponse
            )
        } else if properties.contains(.writeWithoutResponse) {
            peripheral.writeValue(
                data,
                for: characteristic,
                type: .withoutResponse
            )
        } else {
            failConnection(
                message: "Adapter cannot accept commands.",
                reason: "No writable Bluetooth characteristic was found."
            )
        }
    }

    private func handleResponse(_ rawResponse: String) {
        guard let command = currentCommand else {
            return
        }

        let response = cleanResponse(rawResponse)
        currentCommand = nil

        switch command.purpose {
        case .initialization:
            handleInitializationResponse(
                response,
                command: command.text
            )

        case .speed:
            if let value = parsePID(response, prefix: "410D"),
               let speed = value.first {
                updateSpeed(Int(speed))
            }

        case .rpm:
            if let value = parsePID(response, prefix: "410C"),
               value.count >= 2 {
                telemetry.rpm =
                    (Int(value[0]) * 256 + Int(value[1])) / 4
            }

        case .coolant:
            if let value = parsePID(response, prefix: "4105"),
               let temperature = value.first {
                telemetry.coolantTempC = Int(temperature) - 40
            }

        case .distance:
            if let value = parsePID(response, prefix: "4131"),
               value.count >= 2 {
                let rawDistance =
                    Int(value[0]) * 256 + Int(value[1])

                telemetry.distanceSinceCodesClearedKm =
                    Double(rawDistance)
            }

        case .battery:
            if let value = parsePID(response, prefix: "4142"),
               value.count >= 2 {
                let millivolts =
                    Int(value[0]) * 256 + Int(value[1])

                telemetry.batteryVoltage =
                    Double(millivolts) / 1000.0
            }

        case .adapterVoltage:
            // ATRV reports adapter supply voltage. Use it only as
            // a fallback because it may not equal terminal voltage.
            if telemetry.batteryVoltage == nil,
               let voltage = parseAdapterVoltage(response) {
                telemetry.batteryVoltage = voltage
            }

        case .storedDTC:
            telemetry.storedCodes = parseDTCs(
                response,
                modePrefix: "43",
                category: "Stored"
            )
            completedDTCResponses += 1

        case .pendingDTC:
            telemetry.pendingCodes = parseDTCs(
                response,
                modePrefix: "47",
                category: "Pending"
            )
            completedDTCResponses += 1

        case .permanentDTC:
            telemetry.permanentCodes = parseDTCs(
                response,
                modePrefix: "4A",
                category: "Permanent"
            )
            completedDTCResponses += 1
        }

        publish()

        // Continue on the next main-queue cycle to allow BLE callbacks.
        DispatchQueue.main.async { [weak self] in
            self?.processNextCommand()
        }
    }

    private func handleInitializationResponse(
        _ response: String,
        command: String
    ) {
        if response.contains("UNABLETOCONNECT")
            || response.contains("BUSINITERROR")
            || response.contains("CANERROR") {

            failECUConnection(
                message: "Vehicle ECU did not respond.",
                reason: "Turn the ignition on and check adapter compatibility, vehicle OBD support and the OBD fuse."
            )
            return
        }

        if command == "0100" {
            if response.contains("4100") {
                isInitializingECU = false

                telemetry.state = .ecuConnected
                telemetry.statusMessage =
                    "Vehicle ECU connected successfully."
                telemetry.ecuErrorReason = nil

                lastSpeedUpdate = nil
                pollingIndex = 0
            } else {
                failECUConnection(
                    message: "Could not communicate with the vehicle ECU.",
                    reason: "Check the ignition, OBD adapter and vehicle compatibility."
                )
            }
        }
    }

    private func handleQueueFinished() {
        if isScanningDTCs && completedDTCResponses >= 3 {
            isScanningDTCs = false
            telemetry.isScanningDTCs = false
            telemetry.hasCompletedDTCScan = true

            let total =
                telemetry.storedCodes.count
                + telemetry.pendingCodes.count
                + telemetry.permanentCodes.count

            telemetry.dtcScanMessage = total == 0
                ? "Scan complete. No codes were reported by the ECU."
                : "Scan complete. Found \(total) code(s)."

            publish()
        }

        if isInitializingECU {
            // A response to 0100 is what confirms ECU communication.
            return
        }

        guard case .ecuConnected = telemetry.state else {
            return
        }

        if isScanningDTCs {
            return
        }

        scheduleNextPollingCycle()
    }

    // MARK: - Live polling

    private func scheduleNextPollingCycle() {
        guard !isPolling else {
            return
        }

        isPolling = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard case .ecuConnected = self.telemetry.state else {
                self.isPolling = false
                return
            }

            self.pollingIndex = 0
            self.commandQueue = self.pollingCommands
            self.isPolling = false
            self.processNextCommand()
        }
    }

    private func updateSpeed(_ speed: Int) {
        let now = Date()

        if let previous = lastSpeedUpdate {
            let elapsedHours =
                now.timeIntervalSince(previous) / 3600.0

            if elapsedHours > 0 && elapsedHours < 10 {
                telemetry.tripDistanceKm +=
                    Double(max(0, speed)) * elapsedHours
            }
        }

        lastSpeedUpdate = now
        telemetry.speedKmh = max(0, speed)
    }

    // MARK: - Response parsing

    private func cleanResponse(_ response: String) -> String {
        response
            .uppercased()
            .replacingOccurrences(of: ">", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\t", with: "")
    }

    private func parsePID(
        _ response: String,
        prefix: String
    ) -> [UInt8]? {
        let cleaned = cleanResponse(response)

        guard let range = cleaned.range(of: prefix) else {
            return nil
        }

        let payload = String(cleaned[range.upperBound...])

        guard payload.count >= 2, payload.count % 2 == 0 else {
            return nil
        }

        var bytes: [UInt8] = []
        var index = payload.startIndex

        while index < payload.endIndex {
            let next = payload.index(index, offsetBy: 2)

            guard let byte = UInt8(
                payload[index..<next],
                radix: 16
            ) else {
                return nil
            }

            bytes.append(byte)
            index = next
        }

        return bytes
    }

    private func parseAdapterVoltage(_ response: String) -> Double? {
        let cleaned = cleanResponse(response)
            .replacingOccurrences(of: "V", with: "")

        let pattern = #"([0-9]+(?:\.[0-9]+)?)"#

        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: cleaned,
                range: NSRange(cleaned.startIndex..., in: cleaned)
              ),
              let range = Range(match.range(at: 1), in: cleaned) else {
            return nil
        }

        return Double(cleaned[range])
    }

    private func parseDTCs(
        _ response: String,
        modePrefix: String,
        category: String
    ) -> [DTCCode] {
        let cleaned = cleanResponse(response)

        guard let range = cleaned.range(of: modePrefix) else {
            return []
        }

        let payload = String(cleaned[range.upperBound...])

        // A DTC is two bytes. Each pair of bytes forms one code.
        guard payload.count >= 4, payload.count % 2 == 0 else {
            return []
        }

        var bytes: [UInt8] = []
        var index = payload.startIndex

        while index < payload.endIndex {
            let next = payload.index(index, offsetBy: 2)

            guard let byte = UInt8(
                payload[index..<next],
                radix: 16
            ) else {
                return []
            }

            bytes.append(byte)
            index = next
        }

        var codes: [DTCCode] = []
        var i = 0

        while i + 1 < bytes.count {
            let first = bytes[i]
            let second = bytes[i + 1]
            i += 2

            if first == 0 && second == 0 {
                continue
            }

            let prefixIndex = Int((first & 0xC0) >> 6)
            let prefixes = ["P", "C", "B", "U"]

            let digit1 = Int((first & 0x30) >> 4)
            let digit2 = Int(first & 0x0F)
            let digit3 = Int((second & 0xF0) >> 4)
            let digit4 = Int(second & 0x0F)

            let code = String(
                format: "%@%01X%01X%01X%01X",
                prefixes[prefixIndex],
                digit1,
                digit2,
                digit3,
                digit4
            )

            codes.append(
                DTCCode(code: code, category: category)
            )
        }

        return codes
    }

    // MARK: - Connection state helpers

    private func failECUConnection(
        message: String,
        reason: String
    ) {
        isInitializingECU = false
        isPolling = false
        isScanningDTCs = false

        commandQueue.removeAll()
        currentCommand = nil

        telemetry.state = .error(message)
        telemetry.statusMessage = message
        telemetry.ecuErrorReason = reason
        telemetry.isScanningDTCs = false

        publish()
    }

    private func failConnection(
        message: String,
        reason: String
    ) {
        centralManager.stopScan()
        failECUConnection(message: message, reason: reason)
    }

    private func resetConnection() {
        centralManager.stopScan()

        commandQueue.removeAll()
        currentCommand = nil
        responseBuffer = ""

        isInitializingECU = false
        isPolling = false
        isScanningDTCs = false

        connectedPeripheral = nil
        txCharacteristic = nil
        rxCharacteristic = nil
        lastSpeedUpdate = nil

        telemetry.state = .disconnected
        telemetry.statusMessage = "Disconnected"
        telemetry.isScanningDTCs = false

        publish()
    }

    private func publish() {
        delegate?.didUpdateTelemetry(telemetry)
    }
}
