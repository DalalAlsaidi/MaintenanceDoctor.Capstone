//
//  UserModel.swift
//  MaintenceDocker
//
//  Created by Dalal AlSaidi on 2021/12/10.
//

import Foundation

class UserModel {
    
    var id          = ""
    var userName    = ""
    var email       = ""
    var phoneNumber = ""
    var photoUrl    = ""
    var token       = ""
    var userType    = ""
    var gender      = ""
    var birthday    = ""

    
    init () {
        id          = ""
        email       = ""
        userName    = ""
        phoneNumber = ""
        photoUrl    = ""
        token       = ""
        userType    = ""
        gender      = ""
        birthday    = ""
    }
    
    init (id: String, userName: String, email: String, phoneNumber: String, photoUrl: String, token: String, userType: String, gender: String, birthday: String) {
        
        self.id             = id
        self.email          = email
        self.userName       = userName
        self.phoneNumber    = phoneNumber
        self.photoUrl       = photoUrl
        self.token          = token
        self.userType       = userType
        self.gender         = gender
        self.birthday       = birthday
                    
    }    
}
