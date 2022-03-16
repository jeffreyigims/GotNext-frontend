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
        List(contacts) { contact in
            ContactsRowView(contact: contact)
                .padding([.top, .bottom], 8)
        }.listStyle(PlainListStyle())
    }
}

struct ContactsRowView: View {
    @EnvironmentObject var viewModel: ViewModel
    let contact: Contact
    @State var invitingContact: Bool = false
    @State var invited: Bool = false
    @State var recipients: [String] = [String]()
    
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: defaultProfileIcon)
                    .resizable()
                    .frame(width: profileIconSize, height: profileIconSize)
                    .foregroundColor(.black)
                VStack(alignment: .leading) {
                    Text(contact.name()).font(.headline)
                    Text(contact.displayPrettyPhone()).font(.subheadline).foregroundColor(Color(UIColor.darkGray))
                }
                Spacer()
                if self.invited {
                    HStack {
                        Image(systemName: inviteContact)
                            .imageScale(.small)
                            .foregroundColor(.white)
                        Text("Invited")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .frame(width: 77, height: 23)
                    .background(primaryColor)
                    .cornerRadius(4)
                } else {
                    Button(action: {
                        self.recipients = [contact.displayPhone()]
                        self.invitingContact.toggle()
                    }) {
                        HStack {
                            Image(systemName: inviteContact)
                                .imageScale(.small)
                                .foregroundColor(.black)
                            Text("Invite")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        .frame(width: 77, height: 23)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.systemGray, lineWidth: 1)
                        )
                        .background(.white)
                    }.buttonStyle(BorderlessButtonStyle())
                }
            }
            if self.invitingContact {
                MessageSheetView(recipients: self.$recipients, body: $viewModel.inviteMessage, completion: handleDone)
            }
        }
    }
    func handleDone(_ result: MessageComposeResult) {
        switch result {
        case .cancelled:
            break
        case .sent:
            self.invited = true
            break
        case .failed:
            break
        @unknown default:
            break
        }
        self.invitingContact.toggle()
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContactsView(contacts: genericContacts).background(Color(UIColor.secondarySystemBackground))
        }
    }
}

