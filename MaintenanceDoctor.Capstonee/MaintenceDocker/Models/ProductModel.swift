//
//  ProductModel.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/10.
//

import Foundation
import UIKit

class ProductModel {
    var id          = ""
    var name        = ""
    var price       = ""
    var description = ""
    var images      = [String]()
    
    init () {
        id          = ""
        name        = ""
        price       = ""
        description = ""
        images      = [String]()
    }
    
    init (id: String, name: String, price: String, description: String, images: [String]) {
        self.id = id
        self.name = name
        self.price = price
        self.description = description
        self.images = images
    }
}
