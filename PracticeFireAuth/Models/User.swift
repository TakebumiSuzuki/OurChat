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
    
    let authUID: String
    let email: String
    let displayName: String
    let pictureURL: String?
    
    let firstName: String?
    let lastName: String?
    let createdAt: Timestamp
    
    var friendList: [String] = []
    
    
    init(dic: [String: Any], authUID: String, pictureURL: String?){  //String情報からUserオブジェクトを作る。必要ある？
        
        self.authUID = authUID
        self.email = dic["email"] as! String
        self.displayName = dic["displayName"] as! String
        self.pictureURL = pictureURL
        
        self.firstName = dic["firstName"] as? String
        self.lastName = dic["lastName"] as? String
        self.createdAt = dic["createdAt"] as! Timestamp
    }
    
    
    
    static func saveUserToFireStore(authUID: String, email: String, displayName: String, pictureURL: String?, firstName: String?, lastName: String?, createdAt: Timestamp, completion: @escaping (Error?)->Void){
        
        let dictionaryToSave = ["email": email, "displayName": displayName, "pictureURL": pictureURL as Any, "firstName": firstName as Any, "lastName": lastName as Any, "createdAt": createdAt] as [String: Any]
        
        Firestore.firestore().collection("users").document(authUID).setData(dictionaryToSave, merge: true){ (error) in
            
            if error != nil{
                print("Failed to save user info Firestore." ); completion(error) ; return
            }
            print("successfully saved in Firestore")
            completion(nil) //エラーがないのでnilを送る
        }
    }
    
    
    
    static func createUserObjectFromUID(authUID: String, completion: @escaping (Result<User, Error>) -> Void){
        
        Firestore.firestore().collection("users").document(authUID).getDocument { (snapshot, error) in
            
            if error != nil
                {print("Failed to fetch user info from uid from Firestore.")
                completion(.failure(error!))
                return
            }
            
            guard let data = snapshot?.data() else {return}
            let pictureURL = data["pictureURL"] as? String
            let user = User.init(dic: data, authUID: authUID, pictureURL: pictureURL)
            completion(.success(user))
        }
    }
    
    
    static func uploadPictureToFireStorage(){
        
        
    }
    
}
