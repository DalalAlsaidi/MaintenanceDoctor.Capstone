//
//  RepairOrderModel.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/28.
//


import Foundation

class RepairOrderModel {
    var id          = ""
    var name        = ""
    var my_lat      = 0.0
    var my_long     = 0.0
    var description = ""
    var images      = [String]()
    var status      = ""
    
    init () {
        id          = ""
        name        = ""
        my_lat      = 0.0
        my_long     = 0.0
        description = ""
        images      = [String]()
        status      = ""
    }
    
    init (id: String, name: String, my_lat: Double, my_long: Double, description: String, images: [String], status: String) {
        self.id = id
        self.name = name
        self.my_lat = my_lat
        self.my_long = my_long
        self.description = description
        self.images = images
        self.status = status
    }
}
