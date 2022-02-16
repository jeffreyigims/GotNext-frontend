//
//  UtiliyViews.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 2/15/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct ModalButtonView<ButtonContent: View, ModalContent: View>: View {
    let title: String
    @ViewBuilder var buttonContent: ButtonContent
    @ViewBuilder var modalContent: ModalContent
    @State private var isPresented: Bool = false
    var body: some View {
        Button(action: { isPresented.toggle() }) {
            HStack {
                buttonContent
                Spacer()
                Image(systemName: chevronRight)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(12)
        }
        .fullScreenCover(isPresented: $isPresented) {
            ModalView(title: title) {
                modalContent
            }
        }
    }
}

struct ModalView<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        NavigationView {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ModalToolbar(presentationMode: presentationMode, title: title) }
                .background(Color(UIColor.secondarySystemBackground))
                .edgesIgnoringSafeArea(.bottom)
                .customNavigation()
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ModalToolbar: ToolbarContent {
    @Binding var presentationMode: PresentationMode
    let title: String
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { $presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: chevronDown)
            }
        }
        ToolbarItem(placement: .principal) { Text(title).foregroundColor(Color.white) }
    }
}
