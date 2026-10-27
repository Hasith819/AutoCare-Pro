//
//  FormValidator.swift
//  AutoCare-Pro
//
//  Created by Student4 on 2026-10-27.
//

import SwiftUI

enum FormValidator {

    static let fullName = "fullName"
    static let email = "email"
    static let password = "password"
    static let phoneNumber = "phoneNumber"
    static let terms = "terms"

    static func validateFullName(_ value: String) -> String? {
        let name = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty else {
            return "Full name is required."
        }

        guard name.count >= 2 else {
            return "Name must contain at least 2 characters."
        }

        return nil
    }

    static func validateEmail(_ value: String) -> String? {
        let email = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !email.isEmpty else {
            return "Email is required."
        }

        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

        guard email.range(
            of: pattern,
            options: .regularExpression
        ) != nil else {
            return "Enter a valid email address."
        }

        return nil
    }

    static func validatePassword(_ value: String) -> String? {
        guard !value.isEmpty else {
            return "Password is required."
        }

        guard value.count >= 6 else {
            return "Password must be at least 6 characters."
        }

        return nil
    }

    static func validatePhoneNumber(_ value: String) -> String? {
        guard !value.isEmpty else {
            return "Phone number is required."
        }

        let pattern = #"^\+94[0-9]{9}$"#

        guard value.range(
            of: pattern,
            options: .regularExpression
        ) != nil else {
            return "Use +94 followed by exactly 9 digits. Example: +94771234567"
        }

        return nil
    }

    static func validateTerms(_ accepted: Bool) -> String? {
        guard accepted else {
            return "You must accept the Terms & Conditions."
        }

        return nil
    }

    static func validateRegistration(
        fullName: String,
        email: String,
        password: String,
        phoneNumber: String,
        termsAccepted: Bool
    ) -> [String: String] {

        var errors: [String: String] = [:]

        if let error = validateFullName(fullName) {
            errors[Self.fullName] = error
        }

        if let error = validateEmail(email) {
            errors[Self.email] = error
        }

        if let error = validatePassword(password) {
            errors[Self.password] = error
        }

        if let error = validatePhoneNumber(phoneNumber) {
            errors[Self.phoneNumber] = error
        }

        if let error = validateTerms(termsAccepted) {
            errors[Self.terms] = error
        }

        return errors
    }

    static func validateLogin(
        email: String,
        password: String
    ) -> [String: String] {

        var errors: [String: String] = [:]

        if let error = validateEmail(email) {
            errors[Self.email] = error
        }

        if let error = validatePassword(password) {
            errors[Self.password] = error
        }

        return errors
    }
}

struct ValidationErrorText: View {
    let message: String?

    var body: some View {
        Group {
            if let message {
                Label(message, systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
