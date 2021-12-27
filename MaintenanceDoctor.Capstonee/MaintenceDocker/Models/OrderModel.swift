//
//  OrderModel.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/20.
//

import Foundation

class OrderModel {
    var id          = ""
    var name        = ""
    var quantity    = ""
    var image       = ""
    var product_id  = ""
    
    init () {
        id          = ""
        name        = ""
        quantity    = ""
        image       = ""
        product_id  = ""
    }
    
    init (id: String, name: String, quantity: String, image: String, product_id: String) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.image = image
        self.product_id = product_id
    }
}
