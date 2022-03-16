//
//  MessageSheetView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 2/23/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import SwiftUI
import MessageUI

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
            self.parent.completion(result)
        }
    }
}
