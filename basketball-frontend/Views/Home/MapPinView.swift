//
//  MapPinView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 5/5/21.
//  Copyright © 2021 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct MapPinView: View {
  let geometry: GeometryProxy
  
  var body: some View {
    Image(systemName: "mappin")
      .resizable()
      .scaledToFit()
      .frame(width: 45, height: 45)
      .foregroundColor(primaryColor)
      .position(x: geometry.size.width/2, y: geometry.size.height/2-45)
  }
}

struct MapPinView_Previews: PreviewProvider {
  static var previews: some View {
    GeometryReader { geometry in
      MapPinView(geometry: geometry)
    }
  }
}
