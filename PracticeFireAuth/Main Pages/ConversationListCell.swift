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
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .medium
        df.dateStyle = .medium
        return df
    }()
    
    
    var chatRoomObject: ChatRoom?{
        didSet{
            setFriendPicture()
            if let chatRoomObject = chatRoomObject{
                messageTextLabel.text = chatRoomObject.latestMessageText
                let dateInfo = chatRoomObject.latestMessageTime.dateValue()
                timeLabel.text = dateFormatter.string(from: dateInfo)
                newMessageNumberLabel.text = String(chatRoomObject.numberOfNewMessages)
            }
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
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.text = "name"
        return label
    }()
    
    private let messageTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.text = "今日は、今テストで今日は"
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .thin)
        label.text = "12:00"
        return label
    }()
    
    private let newMessageNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.font = .systemFont(ofSize: 12, weight: .thin)
        label.text = "0"
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        setupViews()
    }
    
    private func setFriendPicture(){
        
        if let chatRoomObject = chatRoomObject {
            chatRoomObject.members.forEach { (memberUID) in
                if memberUID != chatRoomObject.myUID{
                    
                    let friendUID = memberUID
                    Firestore.firestore().collection("users").document(friendUID).getDocument { [weak self](snapshot, error) in
                        
                        guard let self = self else{return}
                        if error != nil{print("Firestoreから友達データを取得するのに失敗しました"); return}
                        guard let snapshot = snapshot else{return}
                        guard let dictionary = snapshot.data() else{return}
                        guard let url = dictionary["pictureURL"] as? String else{return}
                        guard let friendName = dictionary["displayName"] as? String else{return}
                        DispatchQueue.main.async {
                            self.imagePicture.sd_setImage(with: URL(string: url), placeholderImage: nil)
                            self.nameLabel.text = friendName
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
        self.contentView.addSubview(messageTextLabel)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(newMessageNumberLabel)
        
        imagePicture.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        imagePicture.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        imagePicture.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imagePicture.widthAnchor.constraint(equalTo: imagePicture.heightAnchor).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: imagePicture.trailingAnchor, constant: 12).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 9).isActive = true
        
        messageTextLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        messageTextLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4).isActive = true
        //messageTextLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 15).isActive = true
        //messageTextLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -13).isActive = true
        
        messageTextLabel.widthAnchor.constraint(equalToConstant: self.contentView.frame.width - 62).isActive = true
        
        timeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: messageTextLabel.bottomAnchor).isActive = true
        
        newMessageNumberLabel.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor).isActive = true
        newMessageNumberLabel.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: 10).isActive = true
    }
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
