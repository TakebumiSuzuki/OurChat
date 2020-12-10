//
//  ChatRoom.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 12/2/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import Foundation
import Firebase

struct ChatRoom{
    
    let members: [String]
    var latestMessageTime: Timestamp
    var latestMessageText: String
    var latestMessageSenderUID: String
    var numberOfNewMessages: Int = 0
    var chatRoomID: String
    
    
    init(dic: [String : Any]){    //FirestoreからのdictionaryからChatRoomオブジェクトを作る
        
        self.members = dic["members"] as? [String] ?? [String]()
        self.latestMessageTime = dic["latestMessageTime"] as? Timestamp ?? Timestamp()
        self.latestMessageText = dic["latestMessageText"] as? String ?? ""
        self.latestMessageSenderUID = dic["latestMessageSenderUID"] as? String ?? ""
        self.numberOfNewMessages = dic["numberOfNewMessages"] as? Int ?? 0
        self.chatRoomID = dic["chatRoomID"] as? String ?? ""
    }
}
