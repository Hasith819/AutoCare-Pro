//
//  ServiceCenter.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//

import Foundation
import CoreLocation
import MapKit

enum ServiceCenterType: String, CaseIterable, Identifiable {
    case authorizedDealer = "Authorized Dealers"
    case repairCenter = "Repair Centers"
    case fuelStation = "Gas Stations"

    var id: String { rawValue }

    var searchQuery: String {
        switch self {
        case .authorizedDealer:
            return "Toyota Lanka"
        case .repairCenter:
            return "car repair"
        case .fuelStation:
            return "Gas"
        }
    }

    var icon: String {
        switch self {
        case .authorizedDealer:
            return "checkmark.seal.fill"
        case .repairCenter:
            return "wrench.and.screwdriver.fill"
        case .fuelStation:
            return "fuelpump.fill"
        }
    }
}

struct ServiceCenter: Identifiable {
    let id = UUID()
    let name: String
    let phoneNumber: String?
    let coordinate: CLLocationCoordinate2D
    let type: ServiceCenterType
    let distanceInMeters: CLLocationDistance

    init(
        mapItem: MKMapItem,
        type: ServiceCenterType,
        userLocation: CLLocation
    ) {
        let placeCoordinate = mapItem.placemark.coordinate

        self.name = mapItem.name ?? "Unknown location"
        self.phoneNumber = mapItem.phoneNumber
        self.coordinate = placeCoordinate
        self.type = type

        let destination = CLLocation(
            latitude: placeCoordinate.latitude,
            longitude: placeCoordinate.longitude
        )

        self.distanceInMeters = userLocation.distance(from: destination)
    }

    var distanceText: String {
        if distanceInMeters < 1000 {
            return "\(Int(distanceInMeters.rounded())) m away"
        }

        return String(format: "%.1f km away", distanceInMeters / 1000)
    }
}
