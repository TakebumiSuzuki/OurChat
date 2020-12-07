//
//  Message.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 12/2/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import Foundation
import Firebase
import MessageKit

struct Message: MessageType{
    
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    
    static func saveNewMessageToFireStore(newMessage: Message, myUID: String, friendUID: String, friendName: String, chatRoomID: String, completion: @escaping () -> Void){
        //まずは深い階層のmessageよりも、chatの階層に情報を入れる。
        
        let members: [String] = [myUID, friendUID]
        let latestMessageTime = newMessage.sentDate
        let latestMessageSenderUID = myUID
        
        var latestMessageText = ""
        switch newMessage.kind {
        case .text(_):
            break
        case .attributedText(let attributedString):  //せっかくattributedでオブジェクトを作ったが、FireStoreに保存するので普通のStringに直す。
            latestMessageText = attributedString.string
        case .photo(_):
            latestMessageText = "a photo sent"
        case .video(_):
            latestMessageText = "a video sent"
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_):
            break
        case .linkPreview(_):
            break
        }
        
        let dictionaryForChatRoomInfo = [
            "members": members,
            "latestMessageTime": latestMessageTime,
            "latestMessageText": latestMessageText,
            "latestMessageSenderUID": latestMessageSenderUID,
            "chatRoomID": chatRoomID] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").document(chatRoomID).setData(dictionaryForChatRoomInfo, merge: true) { (error) in
            if error != nil{print("FirestoreへのchatRoom情報記入に失敗しました。\(error!)"); return}
            
            
            //次にmessage階層に情報を入れる
            let messageId = newMessage.messageId
            
            var contentString = ""
            var thumbnailURL = ""
            switch newMessage.kind {
            case .text(_):
                break
            case .attributedText(let attributedString): //上のchatRoomの時と同様、FireStoreに保存するためにStringに直す。
                contentString = attributedString.string
            case .photo(let photoMedia):
                guard let url = photoMedia.url else{return}
                contentString = url.absoluteString
            case .video(let videoMedia):
                guard let DownloadURL = videoMedia.url, let media = videoMedia as? Media else{return}
                contentString = DownloadURL.absoluteString
                thumbnailURL = media.thumbnailURL
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_):
                break
            case .linkPreview(_):
                break
            }
            
            let dictionaryForMessageInfo = [
                "Sender": ["senderID": newMessage.sender.senderId , "displayName": newMessage.sender.displayName],
                "messageId": newMessage.messageId,
                "sentDate": newMessage.sentDate,
                "kind": newMessage.kind.messageKindString,  //ここに種類をテキストとして書いておく事が重要。
                "messageText": contentString,
                "thumbnailURL": thumbnailURL] as [String : Any]
            
            Firestore.firestore().collection("chatRooms").document(chatRoomID)
                .collection("messages").document(messageId).setData(dictionaryForMessageInfo) { (error) in
                    if error != nil{print("Firestoreへのmessage情報記入に失敗しました。\(error!)"); return}
                    
                    completion()
            }
        }
    }
}

struct Sender: SenderType{
    
    var senderId: String
    var displayName: String
}

struct Media: MediaItem{
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    var thumbnailURL = ""
}

extension MessageKind{
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"//この文字列をChatRoomVCのfetchメソッドの中で使う
        case .photo(_):
            return "photo"//この文字列をChatRoomVCのfetchメソッドの中で使う
        case .video(_):
            return "video"//この文字列をChatRoomVCのfetchメソッドの中で使う
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .custom(_):
            return "customc"
        case .linkPreview(_):
            return "linkPreview"
        }
    }
    
}

