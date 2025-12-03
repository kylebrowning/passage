import Foundation

// MARK: - Phone Delivery

public extension Passage {

    /// Protocol for sending verification SMS/calls.
    /// Implementations handle message formatting and delivery.
    protocol PhoneDelivery: Sendable {
        /// Send a verification code via SMS
        func sendPhoneVerification(
            to phone: String,
            code: String,
            user: any User
        ) async throws

        /// Send verification success confirmation
        func sendVerificationConfirmation(
            to phone: String,
            user: any User
        ) async throws

        /// Send password reset code via SMS
        func sendPasswordResetSMS(
            to phone: String,
            code: String,
            user: any User
        ) async throws

    }

}
