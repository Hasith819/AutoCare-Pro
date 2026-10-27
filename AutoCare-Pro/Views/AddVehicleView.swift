
import SwiftUI

struct AddVehicleView: View {

    @State private var brand = ""
    @State private var model = ""
    @State private var registrationNumber = ""
    @State private var chassisNumber = ""
    @State private var licenseExpiry = ""
    @State private var insuranceExpiry = ""
    @State private var odometerReading = ""

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

             
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Vehicle Information")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.primaryText)

                        Text("Enter your vehicle details to add it to your garage.")
                            .font(AppFonts.body)
                            .foregroundStyle(AppColors.secondaryLabel)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)


                    settingsSection(title: "BASIC INFORMATION") {
                        VStack(spacing: 0) {
                            inputField(
                                title: "Brand",
                                placeholder: "e.g. Toyota",
                                text: $brand
                            )

                            fieldDivider

                            inputField(
                                title: "Model",
                                placeholder: "e.g. Allion",
                                text: $model
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
                            inputField(
                                title: "Revenue License Expiry",
                                placeholder: "e.g. 30 Nov 2026",
                                text: $licenseExpiry
                            )

                            fieldDivider

                            inputField(
                                title: "Insurance Expiry",
                                placeholder: "e.g. 08 Dec 2026",
                                text: $insuranceExpiry
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
                    }


                    settingsSection(title: "VEHICLE PHOTO") {
                        Button(action: {

                        }) {
                            HStack(spacing: 14) {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                    .foregroundStyle(AppColors.accent)
                                    .frame(width: 48, height: 48)
                                    .background(AppColors.buttonBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Upload Vehicle Photo")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppColors.primaryText)

                                    Text("Choose from camera or photo library")
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
                    }

                    Spacer()
                        .frame(height: 24)
                }
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Add Vehicle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .preferredColorScheme(.dark)
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
}

#Preview {
    NavigationStack {
        AddVehicleView()
    }
}
