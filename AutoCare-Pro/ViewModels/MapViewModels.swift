//
//  MapViewModels.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class MapViewModel: ObservableObject {
    @Published var selectedType: ServiceCenterType = .authorizedDealer
    @Published private(set) var centers: [ServiceCenter] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let searchService = MapSearchService()

    var filteredCenters: [ServiceCenter] {
        centers
            .filter { $0.type == selectedType }
            .sorted { $0.distanceInMeters < $1.distanceInMeters }
    }

    func loadNearbyCenters(
        around location: CLLocation
    ) async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            centers = try await searchService.searchNearby(
                around: location
            )

            if centers.isEmpty {
                errorMessage = "No nearby places found. Try again later."
            }
        } catch {
            errorMessage = "Unable to load nearby places. Please try again."
        }
    }
}
