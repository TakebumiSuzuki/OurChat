//
//  User.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/21/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import Foundation
import Firebase

struct User{
    let firstName: String
    let lastName: String
    let email: String
    let userID: String
    let createdAt: Timestamp
    let pictureURL: String
    
    init(dic: [String: Any], userID: String, pictureURL: String){
        self.firstName = dic["firstName"] as! String
        self.lastName = dic["lastName"] as! String
        self.email = dic["email"] as! String
        self.createdAt = dic["createdAt"] as! Timestamp
        self.userID = userID
        self.pictureURL = pictureURL
    }
}
