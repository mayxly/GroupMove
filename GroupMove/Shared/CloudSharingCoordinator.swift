//
//  CloudSharingCoordinator.swift
//  GroupMove
//
//  Created by Johnny Leung on 2024-05-02.
//

import CloudKit
import SwiftUI

struct CloudSharingView: UIViewControllerRepresentable {
  let share: CKShare
  let container: CKContainer
  let property: Property

  func makeCoordinator() -> CloudSharingCoordinator {
    CloudSharingCoordinator(property: property)
  }

  func makeUIViewController(context: Context) -> UICloudSharingController {
    share[CKShare.SystemFieldKey.title] = property.name
    let controller = UICloudSharingController(share: share, container: container)
    controller.modalPresentationStyle = .formSheet
    controller.delegate = context.coordinator
    return controller
  }

  func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {
  }
}

final class CloudSharingCoordinator: NSObject, UICloudSharingControllerDelegate {
  let stack = CoreDataStack.shared
  let property: Property
  init(property: Property) {
    self.property = property
  }

  func itemTitle(for csc: UICloudSharingController) -> String? {
    property.name
  }

  func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
    print("Failed to save share: \(error)")
  }

  func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
    print("Saved the share")
  }

  func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
  }
}

