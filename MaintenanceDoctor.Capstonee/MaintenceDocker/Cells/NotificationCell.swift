//
//  NotificationCell.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/8.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var notificationImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var entity : NotificationModel! {
        didSet {
            notificationImageView.kf.setImage(
                with: URL(string: entity.image_url),
                placeholder: UIImage(named: "placeholder"))
            notificationImageView.kf.indicatorType = .activity
            contentLabel.text = entity.description
        }
    }
    
    
}
