import Foundation
import UIKit
import SwiftUI

enum Base64ImageStorage {
    private static let imageCache = NSCache<NSString, UIImage>()

    static func encode(_ image: UIImage, quality: CGFloat = 0.85) -> String? {
        guard let data = image.jpegData(compressionQuality: quality) else {
            return nil
        }

        return data.base64EncodedString()
    }

    static func decode(_ base64String: String?) -> UIImage? {
        guard let base64String,
              !base64String.isEmpty,
              !base64String.hasPrefix("http") else {
            return nil
        }

        let cacheKey = NSString(string: String(base64String.hashValue))
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            return cachedImage
        }

        guard let data = Data(base64Encoded: base64String),
              let decodedImage = UIImage(data: data) else {
            return nil
        }

        imageCache.setObject(decodedImage, forKey: cacheKey)

        return decodedImage
    }

    static func image(_ base64String: String?) -> Image? {
        guard let image = decode(base64String) else {
            return nil
        }

        return Image(uiImage: image)
    }
}
