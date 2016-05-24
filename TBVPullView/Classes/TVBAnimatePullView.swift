//
//  TVBHeaderView.swift
//  TVBAnimatePullView
//
//  Created by tripleCC on 16/5/18.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TVBAnimatePullView: TVBPullView {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = self.images?.first
        imageView.contentMode = .ScaleAspectFit
        self.addSubview(imageView)
        return imageView
    }()
    var images: [UIImage]?
    var animatedImage: UIImage?
    
    
    convenience init(type: TVBPullViewType, triggeringImages: [UIImage], loadingImages: [UIImage], backgroundColor: UIColor, refreshingCallBack: ((refreshView: TVBPullView) -> Void)) {
        self.init(type: type, triggeringImages: triggeringImages, animatedImage: UIImage.animatedImageWithImages(loadingImages, duration: 1.5), backgroundColor: backgroundColor, refreshingCallBack: refreshingCallBack)
    }
    
    init(type: TVBPullViewType, imageName: String, backgroundColor: UIColor, refreshingCallBack: ((refreshView: TVBPullView) -> Void)) {
        if let gifURL = NSBundle.mainBundle().URLForResource(imageName, withExtension: nil) {
            if let data = NSData(contentsOfURL: gifURL) {
                images = UIImage.imagesWithGifData(data)
            }
        }
        if let images = images {
            self.animatedImage = UIImage.animatedImageWithImages(images, duration: 1.5)
        }
        super.init(frame: .zero)
        self.refreshingCallBack = refreshingCallBack
        self.pullViewType = type
        self.backgroundColor = backgroundColor
    }

    init(type: TVBPullViewType, triggeringImages: [UIImage], animatedImage: UIImage?, backgroundColor: UIColor, refreshingCallBack: ((refreshView: TVBPullView) -> Void)) {
        self.images = triggeringImages
        self.animatedImage = animatedImage
        super.init(frame: .zero)
        self.refreshingCallBack = refreshingCallBack
        self.pullViewType = type
        self.backgroundColor = backgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func adjustInterfaceByRefreshState(refreshState: TVBRefreshState,
                                                triggerPercent: CGFloat) {
        switch refreshState {
        case .None:
            imageView.image = images?.first
        case .Triggering:
            guard let images = images else { return }
            let index = Int(triggerPercent * CGFloat(images.count - 1))
            if imageView.image != images[index] {
                imageView.image = images[index]
            }
        case .Triggered: fallthrough
        case .Loading:
            if imageView.image != animatedImage {
                imageView.image = animatedImage
            }
        default:
            break
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
}
