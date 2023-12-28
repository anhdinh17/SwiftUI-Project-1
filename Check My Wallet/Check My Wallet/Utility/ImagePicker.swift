//
//  ImagePicker.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 12/27/23.
//

import Foundation
import UIKit
import SwiftUI

// File này làm theo công thức trong sách SwiftUI iOS 16

struct ImagePicker: UIViewControllerRepresentable {
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @Binding var selectedImage: UIImage
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    /**
     The Coordinator class is used to save the user's selected photo into the selectedImage binding. Rồi thằng này bind với "userImage" của ProfileView (.fullScreenCover) -> Khi user chọn image or take image thì userImage của ProfileView cũng sẽ thay đổi.
     It conforms to the UIImagePickerControllerDelegate protocol and implement the imagePickerController(_:didFinishPickingMediaWithInfo) method.
     */
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            parent.dismiss()
        }
    }
}

