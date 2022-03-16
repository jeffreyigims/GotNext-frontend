//
//  SplashView.swift
//  basketball-frontend
//
//  Created by Jeff Xu on 11/29/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct SplashView: View {
    
    var body: some View {
        VStack {
            Image("logo")
            Text("Warming up...")
                .font(.largeTitle)
                .foregroundColor(primaryColor)
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
