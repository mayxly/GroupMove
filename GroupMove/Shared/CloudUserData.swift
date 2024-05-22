//
//  CloudUserData.swift
//  GroupMove
//
//  Created by Johnny Leung on 2024-05-20.
//

import CloudKit

final class CloudUserData: ObservableObject {
    enum CloudKitError: LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknown
    }
    
    @Published var isSignedInToiCloud: Bool = false
    @Published var isSignedInError: CloudKitError?
    
    @Published var fullName: String = ""
    
    static let shared = CloudUserData()
    
    init() {
        Task {
            do {
                try await self.getiCloudStatus()
            } catch {
                DispatchQueue.main.async {
                    self.isSignedInError = .iCloudAccountUnknown
                }
            }
        }
    }
}

extension CloudUserData {
    private func getiCloudStatus() async throws {
        let status = try await CKContainer.default().accountStatus()
        
        DispatchQueue.main.async {
            switch status {
            case .available:
                self.isSignedInToiCloud = true
            case .noAccount:
                self.isSignedInError = .iCloudAccountNotFound
            case .couldNotDetermine:
                self.isSignedInError = .iCloudAccountNotDetermined
            case .restricted:
                self.isSignedInError = .iCloudAccountRestricted
            default:
                self.isSignedInError = .iCloudAccountUnknown
            }
        }
    }
}
