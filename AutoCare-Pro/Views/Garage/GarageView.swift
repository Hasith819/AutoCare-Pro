//
//  GarageView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-26.
//
import SwiftUI

struct GarageView: View {

    @EnvironmentObject private var snackBarManager: SnackBarManager
    @EnvironmentObject private var authService: AuthService

    @State private var profilePhotoBase64 = ""
    @State private var ownerName = ""

    @ObservedObject var viewModel: GarageViewModel
    let onVehicleChanged: (() -> Void)?

    @State private var showUserSettings = false
    @State private var showVehicleForm = false
    @State private var showVehicleDropdown = false
    @State private var showDeleteConfirmation = false

    @State private var editingVehicle: Vehicle?
    @State private var vehicleToDelete: Vehicle?
    @State private var selectedVehicleID: UUID?
    @State private var activeVehicleImage: UIImage?

    init(
        viewModel: GarageViewModel = GarageViewModel(),
        onVehicleChanged: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onVehicleChanged = onVehicleChanged
    }

    private var activeVehicle: Vehicle? {
        viewModel.vehicles.first { $0.id == selectedVehicleID }
            ?? viewModel.vehicles.first
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {


                headerSection
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 16)
                    .background(AppColors.background)


                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        activeVehicleCard
                            .padding(.horizontal, 20)

                        if showVehicleDropdown {
                            VehicleDropdownView(
                                vehicles: viewModel.vehicles,
                                selectedVehicleID: activeVehicle?.id,
                                onSelect: { vehicle in
                                    selectedVehicleID = vehicle.id
                                    showVehicleDropdown = false
                                    snackBarManager.show(
                                        "\(vehicle.displayName) selected",
                                        isSuccess: true
                                    )
                                },
                                onEdit: { vehicle in
                                    editingVehicle = vehicle
                                    showVehicleForm = true
                                },
                                onDelete: { vehicle in
                                    vehicleToDelete = vehicle
                                    showDeleteConfirmation = true
                                }
                            )
                            .padding(.horizontal, 20)
                        }

                        addVehicleButton
                            .padding(.horizontal, 20)

                        statsGridSection
                            .padding(.horizontal, 20)

                        dtcAlertBanner
                            .padding(.horizontal, 20)

                        maintenanceExpensesCard
                            .padding(.horizontal, 20)

                        quickActionsSection
                            .padding(.horizontal, 20)

                        Spacer()
                            .frame(height: 30)
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .onAppear {
            viewModel.loadCatalogIfNeeded()
            viewModel.loadVehiclesIfNeeded()
            refreshActiveVehicleImage()
            loadProfilePhoto()
        }
        .onChange(of: selectedVehicleID) { _, _ in
            refreshActiveVehicleImage()
        }
        .onChange(of: viewModel.vehicles) { _, _ in
            if let selectedVehicleID,
               !viewModel.vehicles.contains(where: {
                   $0.id == selectedVehicleID
               }) {
                self.selectedVehicleID = viewModel.vehicles.first?.id
            }
            refreshActiveVehicleImage()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)

        .sheet(
            isPresented: $showUserSettings,
            onDismiss: {
                loadProfilePhoto()
            }
        ) {
            UserSettingsView()
        }

        .sheet(
            isPresented: $showVehicleForm,
            onDismiss: {
                editingVehicle = nil
            }
        ) {
            NavigationStack {
                AddVehicleView(
                    vehicle: editingVehicle,
                    availableBrands: viewModel.brands
                ) { savedVehicle in
                    viewModel.saveVehicle(savedVehicle) { error in
                        if error == nil {
                            selectedVehicleID = savedVehicle.id
                            showVehicleForm = false
                            onVehicleChanged?()

                            if editingVehicle == nil {
                                snackBarManager.show(
                                    "Vehicle added successfully",
                                    isSuccess: true
                                )
                            } else {
                                snackBarManager.show(
                                    "Vehicle updated successfully",
                                    isSuccess: true
                                )
                            }
                        } else {
                            snackBarManager.show(
                                error ?? "Unable to save vehicle",
                                isSuccess: false
                            )
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            showVehicleForm = false
                        }
                        .foregroundStyle(AppColors.secondaryLabel)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }

        .alert(
            "Delete vehicle?",
            isPresented: $showDeleteConfirmation
        ) {
            Button("Cancel", role: .cancel) {
                vehicleToDelete = nil
            }

            Button("Delete", role: .destructive) {
                deleteSelectedVehicle()
            }
        } message: {
            Text("This vehicle will be removed from your garage.")
        }
    }



    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("AutoCare")
                    .font(AppFonts.title2)
                    .foregroundStyle(AppColors.primaryText)

                Text("See your all vehicle status")
                    .font(AppFonts.footer)
                    .foregroundStyle(AppColors.secondaryLabel)
            }

            Spacer()

            Button {
                showUserSettings = true
            } label: {
                if let profileImage = Base64ImageStorage.decode(
                    profilePhotoBase64
                ) {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(AppColors.secondaryLabel)
                }
            }
            .buttonStyle(.plain)
        }
    }



    private var activeVehicleCard: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                showVehicleDropdown.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 6) {
                            Text("ACTIVE GARAGE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(AppColors.accent)

                            Image(
                                systemName: showVehicleDropdown
                                    ? "chevron.up"
                                    : "chevron.down"
                            )
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.accent)
                        }

                        Text(
                            activeVehicle?.displayName
                                ?? "No vehicle selected"
                        )
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.primaryText)
                        .multilineTextAlignment(.leading)

                        Text("Owner: \(ownerName.isEmpty ? "User" : ownerName)")
                            .font(.caption2)
                            .foregroundStyle(AppColors.secondaryLabel)
                    }

                    Spacer()
                }

                ZStack(alignment: .bottomLeading) {
                    if let image = activeVehicleImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)
                            .clipped()
                    } else if let photoURL = activeVehicle?.photoURL,
                              !photoURL.isEmpty {
                        AsyncImage(url: URL(string: photoURL)) { phase in
                            switch phase {
                            case .empty:
                                placeholderVehicleImage

                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 160)
                                    .clipped()

                            case .failure:
                                placeholderVehicleImage

                            @unknown default:
                                placeholderVehicleImage
                            }
                        }
                    } else {
                        placeholderVehicleImage
                    }
                }
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(16)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func refreshActiveVehicleImage() {
        activeVehicleImage = Base64ImageStorage.decode(
            activeVehicle?.photoBase64
        )
    }

    private var placeholderVehicleImage: some View {
        ZStack {
            Rectangle()
                .fill(
                    Color(
                        red: 0.12,
                        green: 0.15,
                        blue: 0.18
                    )
                )
                .frame(height: 160)
                .overlay {
                    LinearGradient(
                        colors: [
                            Color.cyan.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }

            Image(systemName: "car.fill")
                .font(.system(size: 42))
                .foregroundStyle(AppColors.accent)
                .padding(.bottom, 20)
        }
    }



    private var addVehicleButton: some View {
        Button {
            editingVehicle = nil
            showVehicleForm = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")

                Text("Add new Vehicle")
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .foregroundStyle(AppColors.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppColors.buttonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

 

    private func deleteSelectedVehicle() {
        guard let vehicle = vehicleToDelete else { return }

        viewModel.deleteVehicle(vehicle) { error in
            if error == nil {
                if selectedVehicleID == vehicle.id {
                    selectedVehicleID = viewModel.vehicles.first?.id
                }

                vehicleToDelete = nil
                onVehicleChanged?()

                snackBarManager.show(
                    "Vehicle deleted successfully",
                    isSuccess: true
                )
            } else {
                snackBarManager.show(
                    error ?? "Unable to delete vehicle",
                    isSuccess: false
                )
            }
        }
    }



    private var statsGridSection: some View {
        let revenueLicenseStatus = expiryStatus(
            for: activeVehicle?.licenseExpiry
        )
        let insuranceStatus = expiryStatus(
            for: activeVehicle?.insuranceExpiry
        )

        return LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            StatCard(
                title: "ODOMETER",
                value: "\(activeVehicle?.odometerReading ?? "0") km",
                subtitle: activeVehicle != nil
                    ? "Current reading"
                    : "No vehicle available"
            )

            StatCard(
                title: "OBD STATUS",
                value: "Connected",
                subtitle: "Vehicle connection active",
                valueColor: AppColors.accent
            )

            StatCard(
                title: "REVENUE LICENSE",
                value: revenueLicenseStatus.value,
                subtitle: revenueLicenseStatus.subtitle,
                valueColor: revenueLicenseStatus.color
            )

            StatCard(
                title: "INSURANCE",
                value: insuranceStatus.value,
                subtitle: insuranceStatus.subtitle,
                valueColor: insuranceStatus.color
            )
        }
    }

    private func expiryStatus(
        for dateString: String?
    ) -> (value: String, subtitle: String, color: Color) {
        guard let dateString, !dateString.isEmpty else {
            return ("N/A", "No expiry date", .gray)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: dateString) else {
            return ("N/A", "Invalid date", .gray)
        }

        let now = Date()

        if date < now {
            let overdueDays = max(
                1,
                Int(abs(date.timeIntervalSince(now)) / 86400)
            )

            return (
                "Expired",
                "Expired \(overdueDays) day\(overdueDays == 1 ? "" : "s") ago",
                .red
            )
        }

        let remainingDays = max(
            0,
            Int(date.timeIntervalSince(now) / 86400)
        )

        return (
            "\(remainingDays) days",
            "Until expiration",
            remainingDays <= 30 ? .orange : .green
        )
    }



    private var dtcAlertBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.orange)

            Text("2 DTC Fault Codes Detected")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Spacer()
        }
        .padding(16)
        .background(Color.orange.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.5), lineWidth: 1)
        }
    }



    private var maintenanceExpensesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Maintenance expenses")
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryLabel)

                Text("LKR 42,800")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.primaryText)

                Text("Last 6 months")
                    .font(.caption2)
                    .foregroundStyle(AppColors.secondaryLabel)
            }

            HStack(alignment: .bottom, spacing: 16) {
                barView(height: 40)
                barView(height: 80)
                barView(height: 60)
                barView(height: 110)
                barView(height: 70)
                barView(height: 100)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
        }
        .padding(16)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func barView(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(AppColors.accent)
            .frame(width: 28, height: height)
    }



    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("QUICK ACTIONS")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.secondaryLabel)

            HStack(spacing: 10) {
                quickActionButton(
                    title: "Log Service",
                    icon: "plus.square.fill",
                    bg: AppColors.buttonBackground,
                    fg: AppColors.accent
                )

                quickActionButton(
                    title: "Scan OBD",
                    icon: "magnifyingglass",
                    bg: Color.orange.opacity(0.2),
                    fg: .orange
                )

                quickActionButton(
                    title: "Export PDF",
                    icon: "doc.text.fill",
                    bg: Color.green.opacity(0.2),
                    fg: .green
                )
            }
        }
    }

 

    private func loadProfilePhoto() {
        authService.fetchUserProfile { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    profilePhotoBase64 = profile.profilePhotoBase64 ?? ""
                    ownerName = profile.fullName

                case .failure(let error):
                    print(
                        "Failed to load user profile: \(error.localizedDescription)"
                    )
                }
            }
        }
    }



    private func quickActionButton(
        title: String,
        icon: String,
        bg: Color,
        fg: Color
    ) -> some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(fg)

                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(fg)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        GarageView()
            .environmentObject(SnackBarManager())
            .environmentObject(AuthService())
    }
}
