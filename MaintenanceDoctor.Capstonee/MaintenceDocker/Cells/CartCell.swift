//
//  CartCell.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/8.
//

import UIKit
import Kingfisher

class CartCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    
    var quantity = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var entity: CartModel! {
        didSet {
            productImageView.kf.setImage(
                with: URL(string: entity.image),
                placeholder: UIImage(named: "placeholder"))
            productImageView.kf.indicatorType = .activity
            productNameLabel.text = entity.name
            productPriceLabel.text = "$" + entity.price
            quantityLabel.text = entity.quantity
        }
    }

}
