//
//  FriendListCell.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/30/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

protocol FriendListCellDelegate{
    func cellLongPressedGesture(friendUID: String, friendName: String)
    func PushChatRoom(friendUserObject: User)
    func showAddingFriendAlert(friendUID: String, friendName: String, completion: @escaping () -> Void)
    func showUnfriendAlert(friendUID: String, friendName: String, completion: @escaping () -> Void)
}


class FriendListCell: UITableViewCell {
    
    var delegate: FriendListCellDelegate?
    
    var friendUserObject: User?{     //このオブジェクトはTableViewのdequereusableCellからパスされる
        didSet{  //写真と名前をゲット
            if let url = friendUserObject?.pictureURL{
                imagePicture.sd_setImage(with: URL(string: url), placeholderImage: nil)
            }
            nameLabel.text = friendUserObject?.displayName
            if let status = friendUserObject?.status{
                statusLabel.text = status
            }
        }
    }
    
    private var imagePicture: UIImageView = {
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
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 21, weight: .regular)
        return label
    }()
    
    private var statusLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.numberOfLines = 2
        return label
    }()
    
    private var startChatButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 36, weight: .light, scale: .large)
        button.setImage(UIImage(systemName: "message", withConfiguration: symbolConfig), for: .normal)
        button.tintColor = .lightGray
        button.layer.cornerRadius = 7
        button.clipsToBounds = true
        return button
    }()
    
    var addFriendButton: MyCustomButton = {
        let button = MyCustomButton(frame: .zero)   //constraintをつけているので、.zeroで問題ない
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isAdded = true
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        
        addFriendButton.addTarget(self, action: #selector(addFriendButtonTapped), for: .touchUpInside)
        startChatButton.addTarget(self, action: #selector(startChatButtonPressed), for: .touchUpInside)
        
        self.isUserInteractionEnabled = true
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(showUnfriendAlert))
        longPressedGesture.minimumPressDuration = 1.0
        self.addGestureRecognizer(longPressedGesture)
    }
    
    
    @objc private func showUnfriendAlert(){
        
        guard let friendName = friendUserObject?.displayName else{print("Friendの名前の取得に失敗しました"); return}
        guard let friendUID = friendUserObject?.authUID else{print("FriendのauthUID取得に失敗しました"); return}
        delegate?.cellLongPressedGesture(friendUID: friendUID, friendName: friendName)
    }
    
    @objc private func startChatButtonPressed(){
        if let friendUserObject = friendUserObject{
            delegate?.PushChatRoom(friendUserObject: friendUserObject)
        }
    }
    
    private func setupViews(){
        
        contentView.addSubview(imagePicture)
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(startChatButton)
        contentView.addSubview(addFriendButton)
        
        contentView.frame = self.bounds
        
        imagePicture.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        imagePicture.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        imagePicture.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imagePicture.widthAnchor.constraint(equalTo: imagePicture.heightAnchor).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: imagePicture.trailingAnchor, constant: 12).isActive = true
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: startChatButton.leadingAnchor, constant: -10).isActive = true
        
        statusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4).isActive = true
        statusLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: 5).isActive = true
        statusLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
        
        startChatButton.trailingAnchor.constraint(equalTo: addFriendButton.leadingAnchor, constant: -10).isActive = true
        startChatButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        startChatButton.heightAnchor.constraint(equalTo: startChatButton.widthAnchor).isActive = true
        startChatButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addFriendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        addFriendButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        addFriendButton.widthAnchor.constraint(equalToConstant: 110).isActive = true
        addFriendButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    
    
    @objc private func addFriendButtonTapped(){
        
        guard let friendUID = friendUserObject?.authUID, let friendName = friendUserObject?.displayName else{
            print("friendUIDオブジェクトからUIDとfriendNameを取得することに失敗しました。")
            return
        }
        if addFriendButton.isAdded == false{   //まだ友達でないなら、"Add"表記にする
            delegate?.showAddingFriendAlert(friendUID: friendUID, friendName: friendName, completion: {
                self.switchButtonState()  //ボタンの表示を変える。
            })
        }else{     //すでに友達なら、"Friend"表記にする
            delegate?.showUnfriendAlert(friendUID: friendUID, friendName: friendName, completion: {
                self.switchButtonState()  //ボタンの表示を変える。
            })
        }
    }
    
    private func switchButtonState(){
        addFriendButton.switchButtonState()
    }
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
