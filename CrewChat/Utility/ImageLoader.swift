//
//  ImageLoader.swift
//  CrewChat
//
//  Created by Karthik Rashinkar on 26/01/26.
//

import Foundation
import UIKit

/// Centralized image loading utility for handling both local and remote images
class ImageLoader {
    static let shared = ImageLoader()
    
    private init() {}
    
    // MARK: - Synchronous Loading (for local files)
    
    /// Load image from local file system using multiple fallback strategies
    func loadLocalImage(from path: String) -> UIImage? {
        guard !path.hasPrefix("http") else { return nil }
        
        // Strategy 1: Direct path
        if let image = UIImage(contentsOfFile: path) {
            print(" Loaded image from direct path")
            return image
        }
        
        // Strategy 2: Reconstruct from Documents directory
        let fileName = (path as NSString).lastPathComponent
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            if let image = UIImage(contentsOfFile: fileURL.path) {
                print(" Loaded image from Documents directory: \(fileURL.path)")
                return image
            }
        }
        
        // Strategy 3: Data initializer
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let image = UIImage(data: data) {
            print(" Loaded image using Data initializer")
            return image
        }
        
        print(" Failed to load image from: \(path)")
        print("   File exists: \(FileManager.default.fileExists(atPath: path))")
        return nil
    }
    
    // MARK: - Asynchronous Loading (for remote URLs)
    
    /// Load image from remote URL
    func loadRemoteImage(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw ImageLoaderError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ImageLoaderError.invalidResponse
        }
        
        guard let image = UIImage(data: data) else {
            throw ImageLoaderError.invalidImageData
        }
        
        print(" Loaded remote image from: \(urlString)")
        return image
    }
    
    // MARK: - Universal Loading (handles both local and remote)
    
    /// Load image from either local path or remote URL
    func loadImage(from path: String) async -> UIImage? {
        if path.hasPrefix("http") {
            // Remote image
            do {
                return try await loadRemoteImage(from: path)
            } catch {
                print(" Failed to load remote image: \(error.localizedDescription)")
                return nil
            }
        } else {
            // Local image - run on background thread
            return await Task.detached(priority: .userInitiated) {
                await self.loadLocalImage(from: path)
            }.value
        }
    }
    
    // MARK: - Image Saving
    
    /// Save image to Documents directory and return the file URL
    func saveImage(_ image: UIImage, fileName: String? = nil, compressionQuality: CGFloat = 0.8) -> URL? {
        guard let data = image.jpegData(compressionQuality: compressionQuality) else {
            print(" Failed to convert image to JPEG data")
            return nil
        }
        
        let finalFileName = fileName ?? "\(UUID().uuidString).jpg"
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print(" Failed to access Documents directory")
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(finalFileName)
        
        do {
            try data.write(to: fileURL)
            print(" Image saved to: \(fileURL.path)")
            return fileURL
        } catch {
            print(" Failed to save image: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    /// Check if an image exists at the given path
    func imageExists(at path: String) -> Bool {
        if path.hasPrefix("http") {
            return false // Can't check remote URLs synchronously
        }
        
        if FileManager.default.fileExists(atPath: path) {
            return true
        }
        
        // Check in Documents directory
        let fileName = (path as NSString).lastPathComponent
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            return FileManager.default.fileExists(atPath: fileURL.path)
        }
        
        return false
    }
    
    /// Get file size for a local image
    func getFileSize(at path: String) -> Int? {
        guard !path.hasPrefix("http") else { return nil }
        
        var finalPath = path
        
        // Try to resolve path if needed
        if !FileManager.default.fileExists(atPath: path) {
            let fileName = (path as NSString).lastPathComponent
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                finalPath = documentsDirectory.appendingPathComponent(fileName).path
            }
        }
        
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: finalPath),
              let fileSize = attributes[.size] as? Int else {
            return nil
        }
        
        return fileSize
    }
}

// MARK: - Error Types

enum ImageLoaderError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidImageData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The provided URL is invalid"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidImageData:
            return "Unable to create image from data"
        }
    }
}
