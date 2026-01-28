//
//  CameraView.swift
//  CrewChat
//
//  Created by Karthik Rashinkar on 15/01/26.
//

import Foundation
import SwiftUI

// Camera View using UIImagePickerController
/*
 Use a UIViewControllerRepresentable instance to create and manage a UIViewController object in your SwiftUI interface.
 */
/// A SwiftUI wrapper around `UIImagePickerController` that presents
/// the device camera and returns a captured image back to SwiftUI.
///
/// This view uses `UIViewControllerRepresentable` to bridge UIKit's
/// camera interface into SwiftUI and communicates results via a `@Binding`.
struct CameraView: UIViewControllerRepresentable {
    
    /// Binding to pass the captured image back to the presenting SwiftUI view.
    /// - This is optional because the user may cancel the camera
    ///         without capturing a photo.
    @Binding var capturedImage: UIImage?
    
    /// Environment dismiss action to close the SwiftUI sheet or fullScreenCover.
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - UIViewControllerRepresentable
    
    /// Creates and configures the `UIImagePickerController` used to present
    /// the system camera interface.
    ///
    /// - Parameter context: The context containing the coordinator.
    /// - Returns: A configured `UIImagePickerController` instance.
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    /// Updates the UIKit view controller when SwiftUI state changes.
    ///
    /// - Note: No dynamic updates are needed for this camera view,
    ///         so this method is intentionally left empty.
    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {
        // No-op
    }
    
    /// Creates the coordinator responsible for handling UIKit delegate callbacks.
    ///
    /// - Returns: A `Coordinator` instance.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    /// A coordinator class that acts as the delegate for
    /// `UIImagePickerController` and bridges UIKit callbacks
    /// back into SwiftUI.
    class Coordinator: NSObject,
                       UIImagePickerControllerDelegate,
                       UINavigationControllerDelegate {
        
        /// Reference to the parent `CameraView` to update SwiftUI state
        /// and perform dismiss actions.
        let parent: CameraView
        
        /// Initializes the coordinator with a reference to the parent view.
        ///
        /// - Parameter parent: The `CameraView` instance that created this coordinator.
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        /// Called when the user successfully captures or selects an image.
        ///
        /// This method extracts the original image from the info dictionary,
        /// updates the SwiftUI binding, and dismisses the camera interface.
        ///
        /// - Parameters:
        ///   - picker: The image picker controller.
        ///   - info: A dictionary containing the captured media information.
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                // Update SwiftUI state with the captured image
                parent.capturedImage = image
            }
            
            // Dismiss the SwiftUI presentation
            parent.dismiss()
        }
        
        /// Called when the user cancels the camera without capturing an image.
        ///
        /// This simply dismisses the camera interface without
        /// updating the captured image.
        ///
        /// - Parameter picker: The image picker controller.
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

