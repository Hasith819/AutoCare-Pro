//
//  MapSearchService.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//

import Foundation
import MapKit
import CoreLocation

final class MapSearchService {
    private let searchRadius: CLLocationDistance = 30000

    func searchNearby(
        around userLocation: CLLocation
    ) async throws -> [ServiceCenter] {
        var results: [ServiceCenter] = []
        var seenPlaces = Set<String>()
        var lastError: Error?

        let region = MKCoordinateRegion(
            center: userLocation.coordinate,
            latitudinalMeters: searchRadius * 2,
            longitudinalMeters: searchRadius * 2
        )

        for type in ServiceCenterType.allCases {
            do {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = type.searchQuery
                request.region = region
                request.resultTypes = .pointOfInterest

                let response = try await MKLocalSearch(
                    request: request
                ).start()

                for item in response.mapItems {
                    let coordinate = item.placemark.coordinate

                    let destination = CLLocation(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )

                    let distance = userLocation.distance(from: destination)

                    guard distance <= searchRadius else {
                        continue
                    }

                    let key = [
                        item.name ?? "",
                        String(format: "%.5f", coordinate.latitude),
                        String(format: "%.5f", coordinate.longitude)
                    ].joined(separator: "-")

                    guard seenPlaces.insert(key).inserted else {
                        continue
                    }

                    results.append(
                        ServiceCenter(
                            mapItem: item,
                            type: type,
                            userLocation: userLocation
                        )
                    )
                }
            } catch {
                lastError = error
                continue
            }
        }

        if results.isEmpty, let lastError {
            throw lastError
        }

        return results.sorted {
            $0.distanceInMeters < $1.distanceInMeters
        }
    }
}
