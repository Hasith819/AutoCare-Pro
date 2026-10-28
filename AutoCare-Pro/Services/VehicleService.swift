import Foundation
import FirebaseAuth
import FirebaseFirestore

final class VehicleService {
    static let shared = VehicleService()

    private let database = Firestore.firestore()

    private var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    func fetchVehicleCatalog(completion: @escaping (Result<[VehicleBrand], Error>) -> Void) {
        database.collection("vehicleCatalog")
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                let brands = (snapshot?.documents.compactMap { document in
                    VehicleBrand.fromFirestore(documentID: document.documentID, data: document.data())
                } ?? []).sorted { $0.name < $1.name }

                completion(.success(brands))
            }
    }

    func fetchVehicles(completion: @escaping (Result<[Vehicle], Error>) -> Void) {
        guard let userID = currentUserID else {
            completion(.failure(
                NSError(
                    domain: "AutoCare",
                    code: 401,
                    userInfo: [NSLocalizedDescriptionKey: "Please sign in to load your vehicles."]
                )
            ))
            return
        }

        database.collection("users")
            .document(userID)
            .collection("vehicles")
            .order(by: "updatedAt", descending: true)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                let vehicles = (snapshot?.documents.compactMap { document in
                    Vehicle.fromFirestore(documentID: document.documentID, data: document.data())
                } ?? []).sorted { $0.brand < $1.brand }

                completion(.success(vehicles))
            }
    }

    func saveVehicle(_ vehicle: Vehicle, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = currentUserID else {
            completion(.failure(
                NSError(
                    domain: "AutoCare",
                    code: 401,
                    userInfo: [NSLocalizedDescriptionKey: "Please sign in to save your vehicle."]
                )
            ))
            return
        }

        let documentID = vehicle.documentID ?? vehicle.id.uuidString

        database.collection("users")
            .document(userID)
            .collection("vehicles")
            .document(documentID)
            .setData(vehicle.toFirestoreData(), merge: true) { error in
                if let error {
                    completion(.failure(error))
                    return
                }

                completion(.success(()))
            }
    }

    func deleteVehicle(_ vehicle: Vehicle, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = currentUserID else {
            completion(.failure(
                NSError(
                    domain: "AutoCare",
                    code: 401,
                    userInfo: [NSLocalizedDescriptionKey: "Please sign in to delete your vehicle."]
                )
            ))
            return
        }

        let documentID = vehicle.documentID ?? vehicle.id.uuidString

        database.collection("users")
            .document(userID)
            .collection("vehicles")
            .document(documentID)
            .delete { error in
                if let error {
                    completion(.failure(error))
                    return
                }

                completion(.success(()))
            }
    }
}
