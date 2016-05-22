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
    lazy var images: [UIImage]? = {
        if let gifURL = NSBundle.mainBundle().URLForResource("animated.gif", withExtension: nil) {
            if let data = NSData(contentsOfURL: gifURL) {
                if let images = UIImage.imagesWithGifData(data) {
                    return images
                }
            }
        }
        return nil
    }()
    lazy var animatedImage: UIImage? = {
        guard let images = self.images else { return nil }
        return UIImage.animatedImageWithImages(images, duration: 1.5)
    }()
    
    init(type: TVBPullViewType, refreshingCallBack: ((refreshView: TVBPullView) -> Void)) {
        super.init(frame: .zero)
        self.refreshingCallBack = refreshingCallBack
        pullViewType = type
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
