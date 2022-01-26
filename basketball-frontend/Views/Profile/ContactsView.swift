//
//  ContactsView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 4/7/21.
//  Copyright © 2021 Matthew Cruz. All rights reserved.
//

import SwiftUI
import Contacts
import MessageUI

struct ContactsView: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var contacts: [Contact]
  
  var body: some View {
    LazyVStack {
      //      VStack {
      ForEach(contacts) { contact in
        ContactsRowView(contact: contact).padding()
        Divider()
      }
    }
    .background(Color.white)
    .cornerRadius(15)
  }
}

struct ContactsRowView: View {
  let contact: Contact
  let size : CGFloat = 38
  
  @State var invitingContact: Bool = false
  @State var recipients: [String] = [String]()
  @State var message: String = "Please come to the game"
  
  var body: some View {
    ZStack {
      HStack {
        Image(systemName: defaultProfile)
          .resizable()
          .frame(width: size, height: size)
          .scaledToFit()
        VStack(alignment: .leading) {
          Text(contact.name()).font(.headline)
          Text(contact.displayPrettyPhone()).font(.subheadline)
        }
        Spacer()
        Button(action: {
          self.recipients = [contact.displayPhone()]
          self.invitingContact.toggle()
        }) {
          HStack {
            Image(systemName: inviteContact)
              .resizable()
              .frame(width: size, height: size)
              .scaledToFit()
            Text("Invite")
          }
        }
      }
      .cornerRadius(15)
      if self.invitingContact {
        MessageSheetView(recipients: self.$recipients, body: self.$message, completion: {_ in self.invitingContact.toggle() })
      }
    }
    //    .sheet(isPresented: $invitingContact, content: { MessageSheetView(recipients: self.$recipients, body: self.$message, completion: handleDone(_:)) })
    //    MessageSheetView(recipients: self.$recipients, body: self.$message, completion: handleDone(_:))
  }
}

func handleDone(_ result: MessageComposeResult) {
  switch result {
  case .cancelled:
    //
    break
  case .sent:
    //
    break
  case .failed:
    //
    break
  @unknown default:
    //
    break
  }
}

struct ContactsView_Previews: PreviewProvider {
  static let contacts: [Contact] = Array(repeating: genericContact, count: 8)
  static var previews: some View {
    NavigationView {
      ContactsView(contacts: contacts).background(Color(UIColor.secondarySystemBackground))
    }
  }
}

