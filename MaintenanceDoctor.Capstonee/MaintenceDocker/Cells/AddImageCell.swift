//
//  AddImageCell.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/9.
//

import UIKit
import Kingfisher

class AddImageCell: UICollectionViewCell {
    
    @IBOutlet weak var addedImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeImageView: UIImageView!
    
    var entity : PostItemImageModel! {
        
        didSet{
            
            if let image = entity.imgFile {
                addedImageView.image = image
            } else if let imageUrl = entity.imgUrl {
                
                addedImageView.kf.setImage(
                    with: URL(string: imageUrl),
                    placeholder: UIImage(named: "placeholder"))
                addedImageView.kf.indicatorType = .activity
            }
        }
    }
    
}
