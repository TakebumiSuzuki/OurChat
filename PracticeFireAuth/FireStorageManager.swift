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
                print("FireStorageへのpictureダウンロードURLを取得できました")
                
                completion(.success(downloadURL))
            }
        }
    }
    
    static func uploadImage(data: Data, chatRoomID: String, myUID: String, completion: @escaping (Result<URL, Error>) -> Void){
        
        let fileName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("imagesUploadedToChatRooms").child(chatRoomID).child(myUID).child("images").child(fileName)
        
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            
            if let error = error{completion(.failure(error)); return}
            
            storageRef.downloadURL { (url, error) in
                
                if let error = error {completion(.failure(error)); return}
                guard let downloadURL = url else{return}
                completion(.success(downloadURL))
            }
        }
    }
    
    static func uploadVideoThumbnail(data: Data, chatRoomID: String, myUID: String, completion: @escaping (Result<URL, Error>) -> Void){
        
        let fileName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("imagesUploadedToChatRooms").child(chatRoomID).child(myUID).child("videoThumbnails").child(fileName)
        
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            
            if let error = error{completion(.failure(error)); return}
            
            storageRef.downloadURL { (url, error) in
                
                if let error = error {completion(.failure(error)); return}
                guard let downloadURL = url else{return}
                completion(.success(downloadURL))
            }
        }
    }
    
    
    
    static func uploadVideo(fileURL: URL, chatRoomID: String, myUID: String, completion: @escaping (Result<URL, Error>) -> Void){
        //iOS13からiPhone内でのURLパスの記述に変更があったようのあでputFile(from:URL)だとエラーになるとのこと。そのためにDataに変換して保存するようにする。
        //参考ページhttps://stackoverflow.com/questions/58104572/cant-upload-video-to-firebase-storage-on-ios-13
        guard let videoData = NSData(contentsOf: fileURL) as Data? else{print("VideoをDataに変換するのに失敗しました"); return}
        
        let fileName = UUID().uuidString + ".mov"  //拡張子.movがないと再生の段でAVPlayerが機能しない。iPhoneで.mp4を扱うのかは不明。
        
        //specify MIME type このmetadata設定はなくても良いみたい
//        let metadata = StorageMetadata()
//        metadata.contentType = "video/quicktime"
        
        let storageRef = Storage.storage().reference().child("imagesUploadedToChatRooms").child(chatRoomID).child(myUID).child("videos").child(fileName)
        
        storageRef.putData(videoData, metadata: nil) { (metadata, error) in
            
            if let error = error{completion(.failure(error)); return}
            
            storageRef.downloadURL { (url, error) in
                
                if let error = error {completion(.failure(error)); return}
                guard let downloadURL = url else{return}
                completion(.success(downloadURL))
            }
        }
    }
    
    
}


