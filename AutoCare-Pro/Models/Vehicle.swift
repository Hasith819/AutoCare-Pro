//
//  Vehicle.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-28.
//


import Foundation

struct Vehicle: Identifiable, Equatable {
    let id: UUID
    var documentID: String?
    var brand: String
    var model: String
    var registrationNumber: String
    var chassisNumber: String
    var licenseExpiry: String
    var insuranceExpiry: String
    var odometerReading: String
    var photoBase64: String?
    var photoURL: String?
    var createdAt: Date?
    var updatedAt: Date?

    var displayName: String {
        "\(brand) \(model) • \(registrationNumber)"
    }

    init(
        id: UUID = UUID(),
        documentID: String? = nil,
        brand: String,
        model: String,
        registrationNumber: String,
        chassisNumber: String = "",
        licenseExpiry: String = "",
        insuranceExpiry: String = "",
        odometerReading: String = "",
        photoBase64: String? = nil,
        photoURL: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.documentID = documentID
        self.brand = brand
        self.model = model
        self.registrationNumber = registrationNumber
        self.chassisNumber = chassisNumber
        self.licenseExpiry = licenseExpiry
        self.insuranceExpiry = insuranceExpiry
        self.odometerReading = odometerReading
        self.photoBase64 = photoBase64
        self.photoURL = photoURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    static func fromFirestore(documentID: String, data: [String: Any]) -> Vehicle? {
        guard let idString = data["id"] as? String,
              let brand = data["brand"] as? String,
              let model = data["model"] as? String,
              let registrationNumber = data["registrationNumber"] as? String else {
            return nil
        }

        let uuid = UUID(uuidString: idString) ?? UUID()

        return Vehicle(
            id: uuid,
            documentID: documentID,
            brand: brand,
            model: model,
            registrationNumber: registrationNumber,
            chassisNumber: data["chassisNumber"] as? String ?? "",
            licenseExpiry: data["licenseExpiry"] as? String ?? "",
            insuranceExpiry: data["insuranceExpiry"] as? String ?? "",
            odometerReading: data["odometerReading"] as? String ?? "",
            photoBase64: data["photoBase64"] as? String ?? data["photoURL"] as? String,
            photoURL: data["photoURL"] as? String,
            createdAt: nil,
            updatedAt: nil
        )
    }

    func toFirestoreData() -> [String: Any] {
        [
            "id": id.uuidString,
            "brand": brand,
            "model": model,
            "registrationNumber": registrationNumber,
            "chassisNumber": chassisNumber,
            "licenseExpiry": licenseExpiry,
            "insuranceExpiry": insuranceExpiry,
            "odometerReading": odometerReading,
            "photoBase64": photoBase64 ?? "",
            "photoURL": photoURL ?? "",
            "createdAt": createdAt ?? Date(),
            "updatedAt": Date()
        ]
    }
}
