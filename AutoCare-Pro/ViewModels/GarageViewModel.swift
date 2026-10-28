import Foundation
import Combine

final class GarageViewModel: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    @Published var brands: [VehicleBrand] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let vehicleService = VehicleService.shared

    func loadCatalogIfNeeded() {
        guard brands.isEmpty else { return }
        loadCatalog()
    }

    func loadVehiclesIfNeeded() {
        guard !isLoading, vehicles.isEmpty else { return }
        loadVehicles()
    }

    func loadCatalog() {
        vehicleService.fetchVehicleCatalog { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let brands):
                    self.brands = brands
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func loadVehicles() {
        isLoading = true
        errorMessage = nil

        vehicleService.fetchVehicles { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let vehicles):
                    self.vehicles = vehicles
                    self.errorMessage = nil
                case .failure(let error):
                    self.vehicles = []
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func saveVehicle(_ vehicle: Vehicle, completion: @escaping (String?) -> Void) {
        vehicleService.saveVehicle(vehicle) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success:
                    if let index = self.vehicles.firstIndex(where: { $0.id == vehicle.id }) {
                        self.vehicles[index] = vehicle
                    } else {
                        self.vehicles.append(vehicle)
                    }
                    self.errorMessage = nil
                    completion(nil)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(error.localizedDescription)
                }
            }
        }
    }

    func deleteVehicle(_ vehicle: Vehicle, completion: @escaping (String?) -> Void) {
        vehicleService.deleteVehicle(vehicle) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success:
                    self.vehicles.removeAll { $0.id == vehicle.id }
                    self.errorMessage = nil
                    completion(nil)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(error.localizedDescription)
                }
            }
        }
    }
}
