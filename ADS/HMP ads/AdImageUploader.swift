//
//  AdImageUploader.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-13.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

enum AdImageUploader {

    // ضغط + تصغير (مهم جداً لصور الكاميرا)
    static func compress(_ data: Data, maxSide: CGFloat = 1280, quality: CGFloat = 0.72) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let resized = resize(image, maxSide: maxSide)
        return resized.jpegData(compressionQuality: quality)
    }

    static func upload(images: [Data], ownerId: String, adId: String) async throws -> [String] {
        var urls: [String] = []
        urls.reserveCapacity(images.count)

        for (index, data) in images.enumerated() {
            let ref = Storage.storage().reference()
                .child("ads/\(ownerId)/\(adId)/img_\(index).jpg")

            let meta = StorageMetadata()
            meta.contentType = "image/jpeg"

            _ = try await putData(ref, data: data, metadata: meta)
            let url = try await downloadURL(ref)
            urls.append(url.absoluteString)
        }

        return urls
    }

    // MARK: - Helpers

    private static func resize(_ image: UIImage, maxSide: CGFloat) -> UIImage {
        let size = image.size
        let maxCurrent = max(size.width, size.height)
        guard maxCurrent > maxSide else { return image }

        let scale = maxSide / maxCurrent
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    private static func putData(_ ref: StorageReference, data: Data, metadata: StorageMetadata) async throws -> StorageMetadata {
        try await withCheckedThrowingContinuation { cont in
            ref.putData(data, metadata: metadata) { meta, error in
                if let error { cont.resume(throwing: error); return }
                cont.resume(returning: meta ?? StorageMetadata())
            }
        }
    }

    private static func downloadURL(_ ref: StorageReference) async throws -> URL {
        try await withCheckedThrowingContinuation { cont in
            ref.downloadURL { url, error in
                if let error { cont.resume(throwing: error); return }
                guard let url else {
                    cont.resume(throwing: NSError(domain: "Storage", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Missing download URL"
                    ]))
                    return
                }
                cont.resume(returning: url)
            }
        }
    }
}
