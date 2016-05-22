//
//  UIImage+GifExtension.swift
//  TVBAnimatePullView
//
//  Created by tripleCC on 16/5/20.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices

extension UIImage {
    static func imagesWithGifData(data: NSData) -> [UIImage]? {
        let mutableOptions = NSMutableDictionary()
        mutableOptions[String(kCGImageSourceShouldCache)] = true
        mutableOptions[String(kCGImageSourceTypeIdentifierHint)] = String(kUTTypeGIF)
        guard let imageSource = CGImageSourceCreateWithData(data, mutableOptions) else { return nil }
        let numberOfFrames = CGImageSourceGetCount(imageSource)
        var mutableImages = [UIImage]()
        for idx in 0..<numberOfFrames {
            if let imageRef = CGImageSourceCreateImageAtIndex(imageSource, idx, mutableOptions) {
                mutableImages.append(UIImage(CGImage: imageRef))
            }
        }
        return mutableImages
    }
}