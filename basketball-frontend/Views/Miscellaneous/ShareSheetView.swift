//
//  ShareSheetView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 1/18/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import SwiftUI
import MessageUI

struct ShareSheetView: UIViewControllerRepresentable {
  //  @EnvironmentObject var viewModel: ViewModel
  typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
  let activityItems: [Any]
  let applicationActivities: [UIActivity]? = nil
  let excludedActivityTypes: [UIActivity.ActivityType]? = nil
  let callback: Callback? = nil
  func makeUIViewController(context: Context) -> UIActivityViewController {
    let controller = UIActivityViewController(
      //      activityItems: viewModel.objectsToShare,
      activityItems: activityItems,
      applicationActivities: applicationActivities)
    controller.excludedActivityTypes = excludedActivityTypes
    controller.completionWithItemsHandler = callback
    return controller
  }
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

protocol MessagessViewDelegate {
  func messageCompletion(result: MessageComposeResult)
}

class MessagessViewController: UIViewController, MFMessageComposeViewControllerDelegate {
  var delegate: MessagessViewDelegate?
  var recipients: [String]?
  var body: String?
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  func displayMessageInterface() {
    let composeVC = MFMessageComposeViewController()
    composeVC.messageComposeDelegate = self
    composeVC.recipients = self.recipients ?? []
    composeVC.body = body ?? ""
    if MFMessageComposeViewController.canSendText() {
      self.present(composeVC, animated: true, completion: nil)
    } else {
      self.delegate?.messageCompletion(result: MessageComposeResult.failed)
    }
  }
  func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    controller.dismiss(animated: true)
    self.delegate?.messageCompletion(result: result)
  }
}

struct MessageSheetView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentationMode
  @Binding var recipients: [String]
  @Binding var body: String
  var completion: ((_ result: MessageComposeResult) -> Void)
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  func makeUIViewController(context: Context) -> MessagessViewController {
    let controller = MessagessViewController()
    controller.delegate = context.coordinator
    controller.recipients = recipients
    controller.body = body
    return controller
  }
  func updateUIViewController(_ uiViewController: MessagessViewController, context: Context) {
    uiViewController.recipients = recipients
    uiViewController.displayMessageInterface()
  }
  class Coordinator: NSObject, UINavigationControllerDelegate, MessagessViewDelegate {
    var parent: MessageSheetView
    init (_ parent: MessageSheetView) {
      self.parent = parent
    }
    func messageCompletion(result: MessageComposeResult) {
      //      self.parent.presentationMode.wrappedValue.dismiss()
      self.parent.completion(result)
    }
  }
}

class MessagesDelegate: NSObject, MFMessageComposeViewControllerDelegate {
  func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    controller.dismiss(animated: true)
  }
}

struct MessagesView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentationMode
  @Binding var recipients: [String]
  @Binding var body: String
  var completion: ((_ result: MessageComposeResult) -> Void)
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  func makeUIViewController(context: Context) -> MFMessageComposeViewController {
    let controller = MFMessageComposeViewController()
    controller.delegate = context.coordinator
    controller.recipients = recipients
    controller.body = body
    return controller
  }
  func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
  class Coordinator: NSObject, UINavigationControllerDelegate {
    var parent: MessagesView
    init (_ parent: MessagesView) {
      self.parent = parent
    }
    func messageCompletion(result: MessageComposeResult) {
      //      self.parent.presentationMode.wrappedValue.dismiss()
      self.parent.completion(result)
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
      print("Done")
      controller.dismiss(animated: true)
    }
  }
}

