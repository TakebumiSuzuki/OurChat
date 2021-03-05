//
//  Authentication.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 3/5/21.
//  Copyright © 2021 TAKEBUMI SUZUKI. All rights reserved.
//

import Foundation
import Firebase

enum CustomApiError: Error{
    case WeakSelfError
    case AuthResultError
    case JpegConversionError
    case AuthDisplayNameError
    case FirestoreSa
    case ImageLinkIsNill
    
    var localizedDescription: String{
        switch self{
        case .WeakSelfError:
            return "WeakSelfError"
        case .AuthResultError:
            return "AuthResultError"
        case .JpegConversionError:
            return "JpegConversionError"
        case .AuthDisplayNameError:
            return "AuthDisplayNameError"
        case .FirestoreSa:
            return "FirestoreSa"
        case .ImageLinkIsNill:
            return "ImageLinkIsNill"
        }
    }
}


class AuthenticationManager{
    
    //FireBaseAuthへの登録作業
    func registerUserToFirebaseAuth(displayName: String, email: String, password: String, profileImage: UIImage, completion: @escaping (Error?) -> Void){
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            
            guard let self = self else { completion(CustomApiError.WeakSelfError); print("selfエラーです。"); return }
            if let error = error { completion(error); return }
            guard let result = result else { completion(CustomApiError.AuthResultError); return }
            
            print("FirebaseAuthへのユーザー登録が成功しました。")
            let authUID = result.user.uid
            
            if profileImage == UIImage(systemName: "plus"){   //ユーザーが写真を選んでいない時はそのままFireStoreへgo!
                self.saveUserInfoToFireStore(displayName: displayName, authUID: authUID, email: email, pictureURL: nil, completion: completion)
            }else{    //ユーザーがオリジナル写真を選んでいた時はFireStorageにセーブ
                self.saveUserPictureToFireStorage(displayName: displayName, authUID: authUID, email: email, profileImage: profileImage, completion: completion)
            }
        }
    }
    
    //写真があればFireStorageに保存
    private func saveUserPictureToFireStorage(displayName: String, authUID: String, email: String, profileImage: UIImage, completion: @escaping (Error?) -> Void){
        
        guard let jpegData = profileImage.jpegData(compressionQuality: 0.3) else{ completion(CustomApiError.JpegConversionError); return}
        
        self.uploadProfileImage(jpegData: jpegData) { (result) in
            switch result{
            case .success(let downloadURL):
                print("ユーザー写真のFireStoregeへの保存に成功しました")
                self.saveUserInfoToFireStore(displayName: displayName, authUID: authUID, email: email, pictureURL: downloadURL, completion: completion)
            case .failure(let error):
                print("ユーザー写真のFireStoregeへの保存に失敗しましたが写真抜きでFireStoreへのセーブ作業に入ります。")
                completion(error)
                self.saveUserInfoToFireStore(displayName: displayName, authUID: authUID, email: email, pictureURL: nil, completion: completion)
            }
        }
    }
    
    //FireAuthに名前の登録、そしてFireStoreにユーザー情報を保存してdismiss
    private func saveUserInfoToFireStore(displayName: String, authUID: String, email: String, pictureURL: String?, completion: @escaping (Error?) -> Void){
        
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges(completion: { (error) in
            if let error = error{   //このchangeRequestのブロックは重要ではないのでErrorを送らない
                print("displayNameのFirebaseAuthへの登録に失敗しました\(error.localizedDescription)")
                return
            }
        })
            
        self.saveUserToFireStore(authUID: authUID, email: email, displayName: displayName, pictureURL: pictureURL, firstName: nil, lastName: nil, createdAt: Timestamp()) { (error) in
            
            if let error = error {
                print("FireStoreへのユーザー情報セーブが失敗しました。")
                completion(error)
                return }
            
            print("FireStoreへのユーザー登録が成功しました")
            completion(nil)
        }
    }
    
    func uploadProfileImage(jpegData: Data, completion: @escaping (Result<String, Error>) -> Void){
        
        let fileName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        
        storageRef.putData(jpegData, metadata: nil) { (metadata, error) in
            if let error = error{
                print(error.localizedDescription)
                completion(.failure(error))
                return
            }
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                    completion(.failure(error))
                    return
                }
                guard let url = url else{ completion(.failure(CustomApiError.ImageLinkIsNill)); return}
                let downloadURL = url.absoluteString
                print("FireStorageへのpictureダウンロードURLを取得できました")
                completion(.success(downloadURL))
            }
        }
    }
    
    
    private func saveUserToFireStore(authUID: String, email: String, displayName: String, pictureURL: String?, firstName: String?, lastName: String?, createdAt: Timestamp, completion: @escaping (Error?) -> Void){
        
        let dictionaryToSave = ["email": email, "displayName": displayName, "pictureURL": pictureURL as Any, "firstName": firstName as Any, "lastName": lastName as Any, "createdAt": createdAt] as [String: Any]
        
        Firestore.firestore().collection("users").document(authUID).setData(dictionaryToSave, merge: true){ (error) in
            
            if error != nil{ print("Failed to save user info Firestore." ); completion(error) ; return }
            
            completion(nil) //エラーがないのでnilを送る
        }
    }
    
    
    
   func FirebaseAuthLoginHandling(email: String, password: String, completion: @escaping (Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error{ completion(error); return }
            completion(nil)
        }
    }
    
}
