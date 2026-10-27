//
//  SnackBarView.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-27.
//


import SwiftUI
import Combine

final class SnackBarManager: ObservableObject {
    @Published var message = ""
    @Published var isPresented = false
    @Published var isSuccess = true

    private var dismissWorkItem: DispatchWorkItem?

    func show(_ message: String, isSuccess: Bool = true) {
        dismissWorkItem?.cancel()

        self.message = message
        self.isSuccess = isSuccess

        withAnimation(.easeInOut(duration: 0.25)) {
            isPresented = true
        }

        let workItem = DispatchWorkItem { [weak self] in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.25)) {
                    self?.isPresented = false
                }
            }
        }

        dismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 3,
            execute: workItem
        )
    }
}

struct SnackBarView: View {
    let message: String
    let isSuccess: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .font(.system(size: 22))

            Text(message)
                .font(.subheadline.weight(.medium))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            isSuccess
                ? Color(red: 0.08, green: 0.42, blue: 0.28)
                : Color(red: 0.60, green: 0.15, blue: 0.15)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(radius: 8)
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
    }
}
