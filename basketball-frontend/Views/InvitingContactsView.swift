//
//  InvitingContactsView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 12/6/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI
import MessageUI

struct InvitingContactsView: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var contactSearch: String = ""
  
  var body: some View {
    let usSearch = Binding(
      get: {
        self.contactSearch },
      set: {
        self.contactSearch = $0;
        search()
      }
    )
    VStack {
      SearchBarView<Contact>(searchText: usSearch)
      ContactsListView(contacts: $viewModel.contactsFiltered)
    }
    .navigationBarTitle("Invite Contacts")
    .onAppear { search() }
  }
  
  func search() {
    viewModel.searchContacts(query: self.contactSearch)
  }
}

struct ContactsListView: View {
  @EnvironmentObject var viewModel: ViewModel
  @Binding var contacts: [Contact]
  var body: some View {
    List {
      ForEach(contacts) { contact in
        ContactRowView(contact: contact, invited: false)
      }
    }
  }
}

struct ContactRowView: View {
  @EnvironmentObject var viewModel: ViewModel
  let contact: Contact
  @State var invited: Bool
  private let messageComposeDelegate = MessageDelegate()
  
  var body: some View {
    HStack {
      contact.picture?.resizable()
        .frame(width: 32.0, height: 32.0)
      Text(contact.name())
      Spacer()
      Button(action: {
        self.inviteContact()
      }) {
        Text(invited ? "Invited" : "Invite")
          .padding()
          .background(invited ? Color.gray : Color.red)
          .foregroundColor(.black)
          .cornerRadius(40)
          .padding(.leading)
      }
    }.alert(isPresented: $viewModel.showAlert) {
      viewModel.alert!
    }
  }
  func inviteContact() {
    viewModel.inviteContact(contact: contact)
//    invited = true
  }
}

// MARK: The message part
extension ContactRowView {
  
  // Delegate for view controller as `MFMessageComposeViewControllerDelegate`
  private class MessageDelegate: NSObject, MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
      // Customize here
      controller.dismiss(animated: true)
    }
  }
  
  // Present an message compose view controller modally in UIKit environment
  private func presentMessageCompose() {
    guard MFMessageComposeViewController.canSendText() else {
      return
    }
    let vc = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
//    let vc = self.findViewController()
    let composeVC = MFMessageComposeViewController()
    composeVC.messageComposeDelegate = messageComposeDelegate
    composeVC.recipients = [contact.displayPhone()]
    composeVC.body = Helper.composeMessage(user: viewModel.user, game: viewModel.game)
    vc?.present(composeVC, animated: true)
  }
}

struct InvitingContactsView_Previews: PreviewProvider {
  static var previews: some View {
    InvitingContactsView()
  }
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
