import Foundation

// MARK: - Passkey Credential

public protocol PasskeyCredential: Sendable {
    associatedtype UserType: User

    var id: String { get }
    var publicKey: [UInt8] { get }
    var currentSignCount: UInt32 { get }
    var user: UserType { get }
    var backupEligible: Bool { get }
    var isBackedUp: Bool { get }
    var createdAt: Date { get }
}
