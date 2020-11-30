//
//  ChatRoomVC.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/28/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType{
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType{
    var senderId: String
    var displayName: String
}

extension MessageKind{
    
}


class ChatRoomVC: MessagesViewController{
    
    var myUID: String?
    var partnerUID: String?
    var chatRoomID: String?
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    
}
