//
//  RepairOrderCell.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2022/1/4.
//

import UIKit

class RepairOrderCell: UITableViewCell {

    @IBOutlet weak var orderImageView: UIImageView!
    @IBOutlet weak var orderNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var entity: RepairOrderModel! {
        didSet {
            orderImageView.kf.setImage(
                with: URL(string: entity.images[0]),
                placeholder: UIImage(named: "placeholder"))
            orderImageView.kf.indicatorType = .activity
            orderNameLabel.text = entity.name
            descriptionLabel.text = entity.description
            if entity.status == "pending" {
                statusLabel.text = "This order is pending."
            } else if entity.status == "accept" {
                statusLabel.text = "This order is accepted."
            } else {
                statusLabel.text = "This order is rejected."
            }
        }
    }

}
