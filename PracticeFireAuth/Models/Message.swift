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
    
    
    static func saveNewMessageToFireStore(newMessage: Message, myUID: String, friendUID: String, chatRoomID: String, completion: @escaping () -> Void){
        //まずは深い階層のmessageよりも、chatの階層に情報を入れる。
        print("---[MessageModel]chat階層へ保存する準備(dic作り)を始めます。----")
        let members: [String] = [myUID, friendUID]
        
        let latestMessageTime = newMessage.sentDate
        
        var latestMessageText = ""
        switch newMessage.kind {
        case .text(let messageText):
            latestMessageText = messageText
        case .attributedText(_):
            break
        case .photo(_):
            latestMessageText = "Your friend sent you a photo."
        case .video(_):
            latestMessageText = "Your friend sent you a video."
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
        
        let latestMessageSenderUID = myUID
        let numberOfNewMessages = 0 //テストで
        
        let dictionaryForChatRoomInfo = [
            "members": members,
            "latestMessageTime": latestMessageTime,
            "latestMessageText": latestMessageText,
            "latestMessageSenderUID": latestMessageSenderUID,
            "numberOfNewMessages": numberOfNewMessages
            ] as [String : Any]
        print("---[MessageModel]chat階層へ保存するdic作りが終わり、これからこれをFirestoreに保存し始めます。")
        Firestore.firestore().collection("chatRooms").document(chatRoomID).setData(dictionaryForChatRoomInfo, merge: true) { (error) in
            if error != nil{print("FirestoreへのchatRoom情報記入に失敗しました。\(error!)"); return}
            print("---[MessageModel]chatRoom階層へのセーブが終了し、message階層へ保存するdic作りを始めます////----")
            //message階層に情報を入れる
            let messageId = newMessage.messageId
            
            var contentString = ""
            switch newMessage.kind {
            case .text(let messageText):
                contentString = messageText
            case .attributedText(_):
                break
            case .photo(let photoMedia):
                guard let url = photoMedia.url else{return}
                contentString = url.absoluteString
            case .video(_):
                latestMessageText = "Your friend sent you a video."
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
                "kind": newMessage.kind.messageKindString,
                "messageText": contentString
                ] as [String : Any]
            print("---[MessageModel]message階層へ保存するdic作りが終わり、これからこれをFirestoreに保存し始めます。")
            Firestore.firestore().collection("chatRooms").document(chatRoomID)
                .collection("messages").document(messageId).setData(dictionaryForMessageInfo) { (error) in
                    if error != nil{print("Firestoreへのmessage情報記入に失敗しました。\(error!)"); return}
                    print("---[MessageModel]message階層への保存が終了しcompletionを呼びます。")
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
}

extension MessageKind{
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
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

