//
//  ConversationListCell.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/28/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ConversationListCell: UITableViewCell {
    
    var chatRoomObject: ChatRoom?{
        didSet{
            setOtherInfo()
            setFriendPictureAndName()
        }
    }
    
    
    private let imagePicture: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.darkGray.cgColor
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let inOutSignView: UIImageView = {
        let sign = UIImageView()
        sign.translatesAutoresizingMaskIntoConstraints = false
        sign.contentMode = .scaleAspectFit
        return sign
    }()
    
    private let messageTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .thin)
        return label
    }()
    
    private let newMessageNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.backgroundColor = .red
        label.clipsToBounds = true
        label.layer.cornerRadius = 11
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.isHidden = true
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        setupViews()
    }
    
    private func setOtherInfo(){
        
        guard let chatRoomObject = chatRoomObject else{return}
        
        messageTextLabel.text = chatRoomObject.latestMessageText
        let date = chatRoomObject.latestMessageTime.dateValue()
        timeLabel.text = Date.getString(date: date)
    }
    
    
    private func setFriendPictureAndName(){
        
        guard let chatRoomObject = chatRoomObject else{return}
        chatRoomObject.members.forEach { (memberUID) in
            if memberUID != chatRoomObject.myUID{ //myUIDはFireStoreからの情報ではなく、インスタンス化時に現在ログインしているクライアントユーザーのUIDを入れている。
                let friendUID = memberUID
                
                Firestore.firestore().collection("users").document(friendUID).getDocument { [weak self](snapshot, error) in
                    
                    guard let self = self else{return}
                    if error != nil{print("Firestoreから友達データを取得するのに失敗しました"); return}
                    guard let snapshot = snapshot, let dictionary = snapshot.data(),
                        let friendName = dictionary["displayName"] as? String,
                        let friendPictureURL = dictionary["pictureURL"] as? String else{return}
                        
                    DispatchQueue.main.async {
                        self.imagePicture.sd_setImage(with: URL(string: friendPictureURL), placeholderImage: nil)
                        self.nameLabel.text = friendName
                    }
                }
                
                let chatRoomID = chatRoomObject.chatRoomID
                Firestore.firestore().collection("chatRooms").document(chatRoomID).getDocument { [weak self](snapshot, error) in
                    
                    guard let self = self else{return}
                    if error != nil{print("chatRoom情報を取得するのに失敗しました"); return}
                    
                    guard let snapshot = snapshot, let dictionary = snapshot.data(),
                        let numberOfNewMessages = dictionary["numberOfNewMessages"] as? Int,
                        let latestMessageSenderUID = dictionary["latestMessageSenderUID"] as? String else{return}
                        
                    if latestMessageSenderUID == friendUID{
                        DispatchQueue.main.async {
                            self.newMessageNumberLabel.isHidden = numberOfNewMessages > 0 ? false : true
                            self.newMessageNumberLabel.text = String(numberOfNewMessages)
                            self.inOutSignView.image = UIImage(systemName: "arrow.down.left")
                            self.inOutSignView.tintColor = .red
                        }
                    }
                    if latestMessageSenderUID == chatRoomObject.myUID{
                        DispatchQueue.main.async{
                            self.inOutSignView.image = UIImage(systemName: "arrow.up.right")
                            self.inOutSignView.tintColor = .green
                        }
                    }
               }
            }
        }
    }
    
    private func setupViews(){
        
        self.contentView.frame = self.bounds
        self.contentView.addSubview(imagePicture)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(inOutSignView)
        self.contentView.addSubview(messageTextLabel)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(newMessageNumberLabel)
        
        imagePicture.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        imagePicture.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        imagePicture.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imagePicture.widthAnchor.constraint(equalTo: imagePicture.heightAnchor).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: imagePicture.trailingAnchor, constant: 12).isActive = true
        
        inOutSignView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2).isActive = true
        inOutSignView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: 2).isActive = true
        inOutSignView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        inOutSignView.widthAnchor.constraint(equalTo: inOutSignView.heightAnchor).isActive = true
        
        messageTextLabel.topAnchor.constraint(equalTo: inOutSignView.topAnchor).isActive = true
        messageTextLabel.leadingAnchor.constraint(equalTo: inOutSignView.trailingAnchor, constant: 8).isActive = true
        messageTextLabel.widthAnchor.constraint(equalToConstant: self.frame.width - 100).isActive = true
        
        timeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -17).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        
        newMessageNumberLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30).isActive = true
        newMessageNumberLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8).isActive = true
        newMessageNumberLabel.widthAnchor.constraint(equalToConstant: 22).isActive = true
        newMessageNumberLabel.widthAnchor.constraint(equalTo: newMessageNumberLabel.heightAnchor).isActive = true
    }
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
