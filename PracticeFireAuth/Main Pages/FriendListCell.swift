//
//  FriendListCell.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/30/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import SDWebImage

protocol DeleteFriendAlertDelegate{
    func cellLongPressedGesture(userUID: String)
}

class FriendListCell: UITableViewCell {
    
    var delegate: DeleteFriendAlertDelegate?
    
    var user: User?{
        didSet{
            if let url = user?.pictureURL{
                imagePicture.sd_setImage(with: URL(string: url), placeholderImage: UIImage(systemName: "cloud"))
            }
            nameLabel.text = user?.displayName
        }
    }
    
    lazy var imagePicture: UIImageView = {
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
    
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 30, weight: .regular)
        return label
    }()
    
    lazy var startChatButton: UIButton = {
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
        
        self.isUserInteractionEnabled = true
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(showDeleteAlert))
        longPressedGesture.minimumPressDuration = 1.0
        self.addGestureRecognizer(longPressedGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func showDeleteAlert(){
        guard let uid = user?.authUID else{print("FriendのauthUID取得に失敗しました"); return}
        delegate?.cellLongPressedGesture(userUID: uid)
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

}
