//
//  CreateGameButtonView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 1/21/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct CreateGameButtonView: View {
    let tap: () -> ()
    var body: some View {
        Button(action: tap) {
            ZStack{
                Circle()
                    .foregroundColor(.white)
                    .frame(width:75, height:75)
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 75, height: 75)
                    .foregroundColor(primaryColor)
                    .shadow(color: .gray, radius: 2, x: 1, y: 1)
            }
        }
    }
}

struct CreateGameButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGameButtonView(tap: {})
    }
}
