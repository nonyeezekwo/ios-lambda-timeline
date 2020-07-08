//
//  VideoCollectionViewCell.swift
//  VideoPost
//
//  Created by Nonye on 7/8/20.
//  Copyright © 2020 Nonye Ezekwo. All rights reserved.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    var videoClip: URL!
    var clipName: String? {
        didSet {
            titleLabel.text = clipName
        }
    }
    var imageName: UIImage? {
        didSet {
            imageView.image = imageName
        }
    }
    
    // MARK: OUTLETS
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}
