//
//  SearchBarView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 11/20/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct SearchBarView<T>: View {
  @Binding var searchText: String
  @State var isEditing: Bool = false
  
  // Simon NJ, appcoda.com
  var body: some View {
    HStack {
      TextField("Search ...", text: $searchText)
        .padding(7)
        .padding(.horizontal, 25)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .onTapGesture {
          self.isEditing = true
        }.overlay(
          HStack {
            Image(systemName: "magnifyingglass")
              .foregroundColor(.gray)
              .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
              .padding(.leading, 8)
            
            if isEditing {
              Button(action: {
                //                self.isEditing = false
                self.searchText = ""                
              }){
                Image(systemName: "multiply.circle.fill")
                  .foregroundColor(.gray)
                  .padding(.trailing, 8)
              }
            }
          }
        )
      if isEditing {
        Button(action: {
          self.isEditing = false
          self.searchText = ""
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }) {
          Text("Cancel")
        }
        .padding(.trailing, 10)
        .transition(.move(edge: .trailing))
        .animation(.default)
      }
    }.padding(5)
  }
}

struct SimpleSearchBarView<T>: View {
  @Binding var searchText: String
  //  @State var val: Bool = false
  
  var body: some View {
    //    let search: Binding<String> = Binding {
    //      self.searchText
    //    } set: { newVal in
    //      self.searchText = newVal
    //      self.val = newVal != "" ? true : false
    //    }
    
    HStack {
      TextField("Search ...", text: $searchText)
        .padding(7)
        .padding(.horizontal, 25)
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(10)
        .overlay(
          HStack {
            Image(systemName: "magnifyingglass")
              .foregroundColor(.gray)
              .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
              .padding(.leading, 8)
            //            if self.val {
            //              Button(action: {
            //                self.searchText = ""
            //              }){
            //                Image(systemName: "multiply.circle.fill")
            //                  .foregroundColor(.gray)
            //                  .padding(.trailing, 8)
            //              }
            //            }
          }
        )
    }
    .padding([.leading, .trailing], 7)
  }
}


struct SearchBarView2<T>: View {
  @Binding var searchText: String
  @Binding var isEditing: Bool
  
  // Simon NJ, appcoda.com
  var body: some View {
    HStack {
      TextField("Search ...", text: $searchText)
        .padding(7)
        .padding(.horizontal, 25)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .onTapGesture {
          self.isEditing = true
        }.overlay(
          HStack {
            Image(systemName: "magnifyingglass")
              .foregroundColor(.gray)
              .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
              .padding(.leading, 8)
            
            if isEditing {
              Button(action: {
                //                self.isEditing = false
                self.searchText = ""
              }){
                Image(systemName: "multiply.circle.fill")
                  .foregroundColor(.gray)
                  .padding(.trailing, 8)
              }
            }
          }
        )
      if isEditing {
        Button(action: {
          self.isEditing = false
          self.searchText = ""
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }) {
          Text("Cancel")
        }
        .padding(.trailing, 10)
        .transition(.move(edge: .trailing))
        .animation(.default)
      }
    }.padding(5)
  }
}

struct SearchBarView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ZStack {
        Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        SimpleSearchBarView<Int>(searchText: .constant(""))
      }
    }
  }
}
