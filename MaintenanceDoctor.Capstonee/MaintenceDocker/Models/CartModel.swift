//
//  CartModel.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/12.
//

import Foundation

class CartModel {
    var id          = ""
    var name        = ""
    var price       = ""
    var quantity    = ""
    var image       = ""
    var product_id  = ""
    
    init () {
        id          = ""
        name        = ""
        price       = ""
        quantity    = ""
        image       = ""
        product_id  = ""
    }
    
    init (id: String, name: String, price: String, quantity: String, image: String, product_id: String) {
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
        self.image = image
        self.product_id = product_id
    }
}
