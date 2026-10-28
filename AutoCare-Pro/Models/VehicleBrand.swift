import Foundation

struct VehicleBrand: Identifiable, Equatable {
    let id: String
    let name: String
    let models: [String]

    init(id: String = UUID().uuidString, name: String, models: [String] = []) {
        self.id = id
        self.name = name
        self.models = models
    }

    static func fromFirestore(documentID: String, data: [String: Any]) -> VehicleBrand? {
        guard let name = data["name"] as? String else { return nil }

        let models = (data["models"] as? [String]) ?? []

        return VehicleBrand(
            id: documentID,
            name: name,
            models: models
        )
    }
}
