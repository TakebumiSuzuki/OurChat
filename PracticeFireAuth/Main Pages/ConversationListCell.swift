//
//  ConversationListCell.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/28/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit

class ConversationListCell: UITableViewCell {
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    let imagePicture: UIImageView = {
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
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.text = "name"
        return label
    }()
    
    let messageTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.text = "今日は、今テストで今日は"
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .thin)
        label.text = "12:00"
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        setupViews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        
        self.contentView.frame = self.bounds
        self.contentView.addSubview(imagePicture)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(messageTextLabel)
        self.contentView.addSubview(timeLabel)
        
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
        
    }
    
    
    func setContents(chatRoom: ChatRoom){
        
    }
    
    
}
