//
//  NotificationsButtonView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 1/21/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct NotificationsButtonView: View {
    @Binding var userGames: [Game]
    let tap: () -> ()
    
    var body: some View {
        let count: Int = userGames.filter { $0.player.status == .invited }.count
        Button(action: tap) {
            ZStack{
                Circle()
                    .foregroundColor(Color.white)
                    .frame(width: 75, height: 75)
                Image(systemName: "envelope.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 75, height: 75)
                    .foregroundColor(primaryColor)
                if count > 0 {
                    ZStack{
                        Circle()
                            .foregroundColor(Color("tabBarColor"))
                            .frame(width: 20, height: 20)
                        Text("\(count)")
                            .foregroundColor(.white)
                    }.offset(x: 20, y: -18)
                }
            }.shadow(color: .gray, radius: 2, x: 1, y: 1)
        }.buttonStyle(PlainButtonStyle())
    }
}

struct NotificationsButtonView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsButtonView(userGames: .constant(genericGames), tap: {})
    }
}
