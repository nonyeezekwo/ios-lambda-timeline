//
//  VideoPlayerView.swift
//  VideoPost
//
//  Created by Nonye on 7/8/20.
//  Copyright © 2020 Nonye Ezekwo. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var videoPlayerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get { return videoPlayerLayer.player }
        set { videoPlayerLayer.player = newValue }
    }
}

