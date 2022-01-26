//
//  Messages.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 4/14/21.
//  Copyright © 2021 Matthew Cruz. All rights reserved.
//

import Foundation
import SwiftUI
import MessageUI

// Credit to Ethan Bonin: https://ethan-bonin.medium.com/sending-a-sms-with-swiftui-961d2f30bd03

protocol MessagesViewDelegate {
  func messageCompletion(result: MessageComposeResult)
}

class MessagesViewController: UIViewController, MFMessageComposeViewControllerDelegate {
  
  var delegate: MessagesViewDelegate?
  var recipients: [String]?
  var body: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("CONTROLLER")
  }
  
  func displayMessageInterface() {
    let composeVC = MFMessageComposeViewController()
    composeVC.messageComposeDelegate = self
    
    // Configure the fields of the interface
    composeVC.recipients = self.recipients ?? [String]()
    composeVC.body = body ?? ""
    
    // Present the view controller modally
    if MFMessageComposeViewController.canSendText() {
      self.present(composeVC, animated: true, completion: nil)
    } else {
      self.delegate?.messageCompletion(result: MessageComposeResult.failed)
    }
  }
  
  func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    print("DISMISS")
    self.delegate?.messageCompletion(result: result)
    controller.dismiss(animated: true)
  }
}

struct MessageUIView: UIViewControllerRepresentable {
  
  // To be able to dismiss itself after successfully finishing with the MessagesUI
  @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject var viewModel: ViewModel

  var recipients: Contact?
  var game: Game?
  var completion: ((_ result: MessageComposeResult) -> Void)
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  func makeUIViewController(context: Context) -> MessagesViewController {
    let controller = MessagesViewController()
    controller.delegate = context.coordinator
    controller.recipients = [recipients?.displayPhone() ?? ""]
    controller.body = "This is the message"
    print("MAKE")
    return controller
  }
  
  func updateUIViewController(_ uiViewController: MessagesViewController, context: Context) {
    uiViewController.recipients = [recipients?.displayPhone() ?? ""]
    uiViewController.displayMessageInterface()
    print("UPDATE")
  }
  
  class Coordinator: NSObject, UINavigationControllerDelegate, MessagesViewDelegate {
    
    var parent: MessageUIView
    
    init(_ controller: MessageUIView) {
      self.parent = controller
    }
    
    func messageCompletion(result: MessageComposeResult) {
      self.parent.presentationMode.wrappedValue.dismiss()
      self.parent.viewModel.activeSheet = .searchingUsers
      self.parent.viewModel.showingSheet = false
      self.parent.completion(result)
      print(self.parent.viewModel.showingSheet)
    }
  }
}
