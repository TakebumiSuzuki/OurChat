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
}

class FriendListCell: UITableViewCell {
    
    var delegate: FriendListCellDelegate?
    
    var friendUserObject: User?{     //このオブジェクトはTableViewのdequereusableCellからパスされる
        didSet{
            if let url = friendUserObject?.pictureURL{
                imagePicture.sd_setImage(with: URL(string: url), placeholderImage: nil)
            }
            nameLabel.text = friendUserObject?.displayName
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
        label.font = .systemFont(ofSize: 30, weight: .regular)
        return label
    }()
    
    private var startChatButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "text.bubble"), for: .normal)
        button.tintColor = .link
        button.layer.cornerRadius = 7
        button.clipsToBounds = true
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        
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
        contentView.addSubview(startChatButton)
        
        contentView.frame = self.bounds
        
        imagePicture.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 35).isActive = true
        imagePicture.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imagePicture.heightAnchor.constraint(equalTo: imagePicture.widthAnchor).isActive = true
        imagePicture.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: imagePicture.trailingAnchor, constant: 25).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        startChatButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -35).isActive = true
        startChatButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        startChatButton.heightAnchor.constraint(equalTo: startChatButton.widthAnchor).isActive = true
        startChatButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
