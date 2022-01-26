//
//  ImagePickerView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 1/25/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) private var presentationMode
  @Binding var image: UIImage
  
  func makeUIViewController(context: Context) -> some UIViewController {
    var config = PHPickerConfiguration()
    config.filter = .images
    let picker = PHPickerViewController(configuration: config)
    picker.delegate = context.coordinator
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: PHPickerViewControllerDelegate {
    private let parent: ImagePickerView
    
    init(_ parent: ImagePickerView) {
      self.parent = parent
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      picker.dismiss(animated: true)
      
      if let image: PHPickerResult = results.first {
        if image.itemProvider.canLoadObject(ofClass: UIImage.self) {
          image.itemProvider.loadObject(ofClass: UIImage.self) { newImage, error in
            if let error = error {
              print("[INFO] can't load image \(error.localizedDescription)")
            } else {
              if let image = newImage as? UIImage {
                self.parent.image = image
              }
            }
          }
        } else {
          print("[INFO] can't load asset")
        }
      } else {
        print("[INFO] not enough results")
      }
    }
  }
}
