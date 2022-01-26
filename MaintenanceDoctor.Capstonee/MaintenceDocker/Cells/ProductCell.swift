//
//  ProductCell.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/8.
//

import UIKit
import Kingfisher

class ProductCell: UICollectionViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    
    var entity : ProductModel! {
        didSet {
            productImageView.kf.setImage(
                with: URL(string: entity.images[0]),
                placeholder: UIImage(named: "placeholder"))
            productImageView.kf.indicatorType = .activity
            productNameLabel.text        = entity.name
            productPriceLabel.text       = "SR".localized + entity.price
            productDescriptionLabel.text = entity.description
        }
    }
}
