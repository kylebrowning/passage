import Foundation
import Vapor
import WebAuthn

// MARK: - Passkey Namespace

public extension Passage {

    struct Passkey: Sendable {
        let request: Request
        let config: Passage.Configuration.Passkey
    }

}

// MARK: - Service Accessors

extension Passage.Passkey {

    var store: any Passage.Store {
        request.store
    }

    var passkeyCredentials: any Passage.PasskeyCredentialStore {
        get throws {
            guard let credentials = store.passkeyCredentials else {
                throw AuthenticationError.passkeyNotConfigured
            }
            return credentials
        }
    }

    var passkeyChallenges: any Passage.PasskeyChallengeStore {
        get throws {
            guard let challenges = store.passkeyChallenges else {
                throw AuthenticationError.passkeyNotConfigured
            }
            return challenges
        }
    }

    var webAuthn: WebAuthnManager {
        request.webAuthn
    }

    var configuration: Passage.Configuration {
        request.configuration
    }

}

// MARK: - Request Extension

extension Request {

    var passkey: Passage.Passkey {
        get throws {
            guard let config = configuration.passkey else {
                throw AuthenticationError.passkeyNotConfigured
            }
            return Passage.Passkey(request: self, config: config)
        }
    }

}

// MARK: - Registration (Authenticated User)

extension Passage.Passkey {

    func beginRegistration(for user: any User) async throws -> PublicKeyCredentialCreationOptions {
        let userId = try user.requiredIdAsString

        let userEntity = PublicKeyCredentialUserEntity(
            id: [UInt8](userId.utf8),
            name: user.email ?? user.username ?? userId,
            displayName: user.email ?? user.username ?? userId
        )

        let options = webAuthn.beginRegistration(
            user: userEntity,
            timeout: config.challengeTimeout,
            attestation: config.attestation
        )

        try await passkeyChallenges.storeChallenge(
            options.challenge,
            for: userId,
            type: .registration
        )

        return options
    }

    func finishRegistration(
        credential: RegistrationCredential,
        for user: any User
    ) async throws {
        let userId = try user.requiredIdAsString

        guard let challenge = try await passkeyChallenges.retrieveAndDeleteChallenge(
            for: userId,
            type: .registration
        ) else {
            throw AuthenticationError.passkeyChallengeNotFound
        }

        let credentialStore = try passkeyCredentials

        do {
            let verified = try await webAuthn.finishRegistration(
                challenge: challenge,
                credentialCreationData: credential,
                confirmCredentialIDNotRegisteredYet: { credentialId in
                    let exists = try await credentialStore.credentialExists(id: credentialId)
                    return !exists
                }
            )

            let credentialId = credential.id.asString()

            try await credentialStore.createCredential(
                id: credentialId,
                publicKey: verified.publicKey,
                signCount: verified.signCount,
                backupEligible: verified.backupEligible,
                isBackedUp: verified.isBackedUp,
                for: user
            )
        } catch is WebAuthnError {
            throw AuthenticationError.passkeyRegistrationFailed
        }
    }

}

// MARK: - Signup (Unauthenticated)

extension Passage.Passkey {

    func beginSignup(username: String?) async throws -> PublicKeyCredentialCreationOptions {
        let tempId = UUID().uuidString

        let displayName = username ?? tempId

        let userEntity = PublicKeyCredentialUserEntity(
            id: [UInt8](tempId.utf8),
            name: displayName,
            displayName: displayName
        )

        let options = webAuthn.beginRegistration(
            user: userEntity,
            timeout: config.challengeTimeout,
            attestation: config.attestation
        )

        let challengeKey = username ?? tempId
        try await passkeyChallenges.storeChallenge(
            options.challenge,
            for: challengeKey,
            type: .registration
        )

        return options
    }

    func finishSignup(
        credential: RegistrationCredential,
        challengeKey: String
    ) async throws -> AuthUser {
        guard let challenge = try await passkeyChallenges.retrieveAndDeleteChallenge(
            for: challengeKey,
            type: .registration
        ) else {
            throw AuthenticationError.passkeyChallengeNotFound
        }

        let credentialStore = try passkeyCredentials

        let verified: WebAuthn.Credential
        do {
            verified = try await webAuthn.finishRegistration(
                challenge: challenge,
                credentialCreationData: credential,
                confirmCredentialIDNotRegisteredYet: { credentialId in
                    let exists = try await credentialStore.credentialExists(id: credentialId)
                    return !exists
                }
            )
        } catch {
            throw AuthenticationError.passkeyRegistrationFailed
        }

        let user = try await store.users.create(
            identifier: .username(challengeKey),
            with: nil
        )

        let credentialId = credential.id.asString()

        try await credentialStore.createCredential(
            id: credentialId,
            publicKey: verified.publicKey,
            signCount: verified.signCount,
            backupEligible: verified.backupEligible,
            isBackedUp: verified.isBackedUp,
            for: user
        )

        request.passage.login(user)

        return try await request.tokens.issue(
            for: user,
            revokeExisting: config.revokeExistingTokens
        )
    }

}

// MARK: - Authentication

extension Passage.Passkey {

    func beginAuthentication() async throws -> PublicKeyCredentialRequestOptions {
        let sessionId = UUID().uuidString

        let options = webAuthn.beginAuthentication(
            timeout: config.challengeTimeout,
            userVerification: config.userVerification
        )

        try await passkeyChallenges.storeChallenge(
            options.challenge,
            for: sessionId,
            type: .authentication
        )

        return options
    }

    func finishAuthentication(
        credential: AuthenticationCredential,
        challengeKey: String
    ) async throws -> AuthUser {
        let credentialId = credential.id.asString()

        let credentialStore = try passkeyCredentials

        guard let storedCredential = try await credentialStore.findCredential(byId: credentialId) else {
            throw AuthenticationError.passkeyCredentialNotFound
        }

        guard let challenge = try await passkeyChallenges.retrieveAndDeleteChallenge(
            for: challengeKey,
            type: .authentication
        ) else {
            throw AuthenticationError.passkeyChallengeNotFound
        }

        let verifiedAuth: VerifiedAuthentication
        do {
            verifiedAuth = try webAuthn.finishAuthentication(
                credential: credential,
                expectedChallenge: challenge,
                credentialPublicKey: storedCredential.publicKey,
                credentialCurrentSignCount: storedCredential.currentSignCount
            )
        } catch {
            throw AuthenticationError.passkeyAuthenticationFailed
        }

        try await credentialStore.updateSignCount(
            verifiedAuth.newSignCount,
            for: credentialId
        )

        let user = storedCredential.user as any User

        request.passage.login(user)

        return try await request.tokens.issue(
            for: user,
            revokeExisting: config.revokeExistingTokens
        )
    }

}
