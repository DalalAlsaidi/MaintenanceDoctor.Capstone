//
//  OrderCell.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/20.
//

import UIKit

class OrderCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var photoImageview: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var entity: OrderModel! {
        didSet {
            photoImageview.kf.setImage(
                with: URL(string: entity.image),
                placeholder: UIImage(named: "placeholder"))
            photoImageview.kf.indicatorType = .activity
            nameLabel.text = entity.name
            countLabel.text = "Order Count: " + entity.quantity
            
        }
    }
}
