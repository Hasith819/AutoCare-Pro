

import SwiftUI
import PhotosUI

struct AddVehicleView: View {

    let vehicle: Vehicle?
    let availableBrands: [VehicleBrand]
    let onSave: (Vehicle) -> Void

    @State private var brand: String
    @State private var model: String
    @State private var registrationNumber: String
    @State private var chassisNumber: String
    @State private var licenseExpiryDate: Date
    @State private var insuranceExpiryDate: Date
    @State private var odometerReading: String
    @State private var vehiclePhotoBase64: String
    @State private var selectedVehiclePhoto: PhotosPickerItem?

    @State private var showValidationError = false

    private var availableModels: [String] {
        availableBrands.first { $0.name == brand }?.models ?? []
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    init(
        vehicle: Vehicle? = nil,
        availableBrands: [VehicleBrand] = [],
        onSave: @escaping (Vehicle) -> Void
    ) {
        self.vehicle = vehicle
        self.availableBrands = availableBrands
        self.onSave = onSave

        let initialBrand = vehicle?.brand ?? ""
        let initialModel = vehicle?.model ?? ""
        let initialLicenseDate = Self.parseDate(vehicle?.licenseExpiry) ?? Date()
        let initialInsuranceDate = Self.parseDate(vehicle?.insuranceExpiry) ?? Date().addingTimeInterval(30 * 24 * 60 * 60)

        _brand = State(initialValue: initialBrand)
        _model = State(initialValue: initialModel)
        _registrationNumber = State(initialValue: vehicle?.registrationNumber ?? "")
        _chassisNumber = State(initialValue: vehicle?.chassisNumber ?? "")
        _licenseExpiryDate = State(initialValue: initialLicenseDate)
        _insuranceExpiryDate = State(initialValue: initialInsuranceDate)
        _odometerReading = State(initialValue: vehicle?.odometerReading ?? "")
        _vehiclePhotoBase64 = State(initialValue: vehicle?.photoBase64 ?? vehicle?.photoURL ?? "")
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(vehicle == nil ? "Add Vehicle" : "Update Vehicle")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.primaryText)

                        Text("Enter your vehicle details.")
                            .font(AppFonts.body)
                            .foregroundStyle(AppColors.secondaryLabel)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    settingsSection(title: "BASIC INFORMATION") {
                        VStack(spacing: 0) {
                            dropdownField(
                                title: "Brand",
                                placeholder: "Select brand",
                                selection: $brand,
                                options: availableBrands.map(\.name)
                            )

                            fieldDivider

                            dropdownField(
                                title: "Model",
                                placeholder: "Select model",
                                selection: $model,
                                options: availableModels,
                                isDisabled: availableModels.isEmpty
                            )

                            fieldDivider

                            inputField(
                                title: "Registration Number",
                                placeholder: "Enter registration number",
                                text: $registrationNumber
                            )

                            fieldDivider

                            inputField(
                                title: "Chassis Number",
                                placeholder: "Enter chassis number",
                                text: $chassisNumber
                            )
                        }
                    }

                    settingsSection(title: "DOCUMENT DETAILS") {
                        VStack(spacing: 0) {
                            dateField(
                                title: "Revenue License Expiry",
                                date: $licenseExpiryDate
                            )

                            fieldDivider

                            dateField(
                                title: "Insurance Expiry",
                                date: $insuranceExpiryDate
                            )
                        }
                    }

                    settingsSection(title: "VEHICLE STATUS") {
                        inputField(
                            title: "Odometer Reading (km)",
                            placeholder: "Enter current mileage",
                            text: $odometerReading,
                            keyboardType: .numberPad
                        )
                        .onChange(of: odometerReading) { _, newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue {
                                odometerReading = filtered
                            }
                        }
                    }

                    settingsSection(title: "VEHICLE PHOTO") {
                        PhotosPicker(selection: $selectedVehiclePhoto, matching: .images) {
                            HStack(spacing: 14) {
                                if let photoImage = Base64ImageStorage.decode(vehiclePhotoBase64) {
                                    Image(uiImage: photoImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 48, height: 48)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                } else {
                                    Image(systemName: "camera.fill")
                                        .font(.title2)
                                        .foregroundStyle(AppColors.accent)
                                        .frame(width: 48, height: 48)
                                        .background(AppColors.buttonBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(vehiclePhotoBase64.isEmpty ? "Upload Vehicle Photo" : "Vehicle Photo Selected")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppColors.primaryText)

                                    Text("Choose from photo library")
                                        .font(.caption)
                                        .foregroundStyle(AppColors.secondaryLabel)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(AppColors.secondaryLabel)
                            }
                            .padding(16)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .onChange(of: selectedVehiclePhoto) { _, newItem in
                            guard let newItem else { return }

                            Task {
                                if let data = try? await newItem.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data),
                                   let encoded = Base64ImageStorage.encode(image) {
                                    await MainActor.run {
                                        vehiclePhotoBase64 = encoded
                                    }
                                }
                            }
                        }
                    }

                    Button(action: saveVehicle) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")

                            Text(vehicle == nil ? "Save Vehicle" : "Update Vehicle")
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .foregroundStyle(AppColors.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(AppColors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)

                    Spacer()
                        .frame(height: 24)
                }
                .padding(.vertical, 12)
            }
        }
        .onAppear {
            if brand.isEmpty, let firstBrand = availableBrands.first?.name {
                brand = firstBrand
            }

            if model.isEmpty, let firstModel = availableModels.first {
                model = firstModel
            }
        }
        .navigationTitle(vehicle == nil ? "Add Vehicle" : "Update Vehicle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .preferredColorScheme(.dark)
        .alert("Missing Information", isPresented: $showValidationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter the vehicle brand, model, registration number, and a valid odometer reading.")
        }
    }

    private func saveVehicle() {
        let cleanBrand = brand.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanModel = model.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanRegistration = registrationNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanOdometer = odometerReading.filter { $0.isNumber }

        guard !cleanBrand.isEmpty,
              !cleanModel.isEmpty,
              !cleanRegistration.isEmpty,
              !cleanOdometer.isEmpty else {
            showValidationError = true
            return
        }

        let savedVehicle = Vehicle(
            id: vehicle?.id ?? UUID(),
            documentID: vehicle?.documentID,
            brand: cleanBrand,
            model: cleanModel,
            registrationNumber: cleanRegistration,
            chassisNumber: chassisNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            licenseExpiry: dateFormatter.string(from: licenseExpiryDate),
            insuranceExpiry: dateFormatter.string(from: insuranceExpiryDate),
            odometerReading: cleanOdometer,
            photoBase64: vehiclePhotoBase64.isEmpty ? nil : vehiclePhotoBase64,
            photoURL: vehicle?.photoURL,
            createdAt: vehicle?.createdAt ?? Date(),
            updatedAt: Date()
        )

        onSave(savedVehicle)
    }

    private func dropdownField(
        title: String,
        placeholder: String,
        selection: Binding<String>,
        options: [String],
        isDisabled: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.secondaryLabel)

            Picker(title, selection: selection) {
                if selection.wrappedValue.isEmpty {
                    Text(placeholder).tag("")
                }

                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.menu)
            .tint(AppColors.primaryText)
            .disabled(isDisabled)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func dateField(title: String, date: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.secondaryLabel)

            DatePicker(
                "",
                selection: date,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .tint(AppColors.accent)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(AppColors.secondaryLabel)
                .padding(.horizontal, 4)

            content()
                .background(AppColors.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 20)
    }

    private func inputField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.secondaryLabel)

            TextField(placeholder, text: text)
                .font(.subheadline)
                .foregroundStyle(AppColors.primaryText)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var fieldDivider: some View {
        Divider()
            .overlay(AppColors.secondaryLabel.opacity(0.2))
            .padding(.leading, 16)
    }

    private static func parseDate(_ value: String?) -> Date? {
        guard let value, !value.isEmpty else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }
}

#Preview {
    NavigationStack {
        AddVehicleView { vehicle in
            print(vehicle.displayName)
        }
    }
}
