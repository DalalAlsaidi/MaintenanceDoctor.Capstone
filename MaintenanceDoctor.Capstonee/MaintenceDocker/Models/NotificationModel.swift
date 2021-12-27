//
//  UserNotificationModel.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/17.
//

import Foundation

class NotificationModel {
    var id                  = ""
    var product_id          = ""
    var description         = ""
    var sender              = ""
    var receiver            = ""
    var image_url           = ""
    var order_ids           = [String]()
    
    init () {
        id              = ""
        product_id      = ""
        description     = ""
        sender          = ""
        receiver        = ""
        image_url       = ""
        order_ids       = [String]()
    }
    
    init (id: String, product_id: String, description: String, sender: String, receiver: String, image_url: String, order_ids: [String]) {
        self.id             = id
        self.product_id     = product_id
        self.description    = description
        self.sender         = sender
        self.receiver       = receiver
        self.image_url      = image_url
        self.order_ids      = order_ids
    }
}
