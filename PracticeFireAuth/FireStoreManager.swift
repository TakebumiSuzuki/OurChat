//
//  FireStoreManager.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 12/9/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import Foundation
import Firebase


class FireStoreManager{
    
    
    static func saveFriendInfoToFireStore(friendUID: String, friendName: String, myUID: String, completion: @escaping() -> Void) {
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        Firestore.firestore().collection("friendLists").document(friendUID).setData([myUID : "confirmed"], merge: true)
        Firestore.firestore().collection("friendLists").document(myUID).setData([friendUID : "confirmed"], merge: true)
        
        dispatchGroup.leave()
        dispatchGroup.notify(queue: .main) {
            
            completion()
        }
    }

    
    static func deleteFriendInfofromFireStore(friendUID: String, friendName: String, myUID: String, completion: @escaping() -> Void){
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        Firestore.firestore().collection("friendLists").document(friendUID).updateData([myUID : FieldValue.delete()]) { (error) in
            if error != nil{print("FireStore内の友達のドキュメント内の、自分UIDフィールドの消去に失敗しました。"); return}
        }
        Firestore.firestore().collection("friendLists").document(myUID).updateData([friendUID : FieldValue.delete()]) { (error) in
            if error != nil{print("FireStore内の自分のフレンドドキュメント内の、FirendUIDフィールド消去に失敗しました。"); return}
        }
        dispatchGroup.leave()
        dispatchGroup.notify(queue: .main) {
            
            completion()
        }
        
    }
    
}

