//
//  File.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/9.
//

import Foundation
import UIKit

class PostItemImageModel {
    
    var imgFile : UIImage?
    var imgUrl : String?
    
    init(imgFile : UIImage) {
        self.imgFile = imgFile
    }
    
    init(imgUrl : String) {
        self.imgUrl = imgUrl
    }
}
