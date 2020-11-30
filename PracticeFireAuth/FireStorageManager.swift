//
//  FireStorageManager.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/22/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import Foundation
import FirebaseStorage

class FireStorageManager{
    
    static func uploadProfileImage(jpegData: Data, completion: @escaping (Result<String, Error>) -> Void){
        
        let fileName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        
        storageRef.putData(jpegData, metadata: nil) { (metadata, error) in
            if let error = error{
                print(error.localizedDescription); return
            }
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print(error.localizedDescription); return
                }
                guard let url = url else{return}
                let downloadURL = url.absoluteString
                print("successfully gotten download URL: \(downloadURL)")
                
                completion(.success(downloadURL))
            }
        }
    }
    
    
    
    
}


