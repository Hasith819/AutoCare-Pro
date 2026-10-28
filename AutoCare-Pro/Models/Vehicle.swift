//
//  Vehicle.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-28.
//


import Foundation

struct Vehicle: Identifiable, Equatable {
    let id: UUID
    var brand: String
    var model: String
    var registrationNumber: String
    var chassisNumber: String
    var licenseExpiry: String
    var insuranceExpiry: String
    var odometerReading: String

    var displayName: String {
        "\(brand) \(model) • \(registrationNumber)"
    }

    init(
        id: UUID = UUID(),
        brand: String,
        model: String,
        registrationNumber: String,
        chassisNumber: String = "",
        licenseExpiry: String = "",
        insuranceExpiry: String = "",
        odometerReading: String = ""
    ) {
        self.id = id
        self.brand = brand
        self.model = model
        self.registrationNumber = registrationNumber
        self.chassisNumber = chassisNumber
        self.licenseExpiry = licenseExpiry
        self.insuranceExpiry = insuranceExpiry
        self.odometerReading = odometerReading
    }
}
