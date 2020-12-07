//
//  SearchFriendCell.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/30/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

protocol SearchFriendCellDelegate{
    func showAddingFriendAlert(friendUID: String, friendName: String, completion: @escaping () -> Void)
    func showUnfriendAlert(friendUID: String, friendName: String, completion: @escaping () -> Void)
}

class SearchFriendCell: UITableViewCell {
    
    var delegate: SearchFriendCellDelegate?
    
    var myFriendListDic = ["" : ""]{
        didSet{
            let friendUID = friendUserObject?.authUID
            for keyValuePair in myFriendListDic{
                print("keyValuePir")
                if keyValuePair == (key: friendUID, value: "confirmed"){
                    
                    setAddButton()
                }
                
            }
        }
    }
    
    var friendUserObject: User?{
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
    
    private var addFriendButton: MyCustomButton = {
        let button = MyCustomButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        print("button created")
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        setupViews()
        addFriendButton.addTarget(self, action: #selector(addFriendButtonTapped), for: .touchUpInside)
        
    }
    
    
    
    private func setupViews(){
        
        contentView.addSubview(imagePicture)
        contentView.addSubview(nameLabel)
        contentView.addSubview(addFriendButton)
        
        contentView.frame = self.bounds
        
        imagePicture.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 35).isActive = true
        imagePicture.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imagePicture.heightAnchor.constraint(equalTo: imagePicture.widthAnchor).isActive = true
        imagePicture.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: imagePicture.trailingAnchor, constant: 25).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        addFriendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -35).isActive = true
        addFriendButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        addFriendButton.widthAnchor.constraint(equalToConstant: 110).isActive = true
        addFriendButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    private func setAddButton(){
        addFriendButton.isAdded = true
    }
    
    @objc private func addFriendButtonTapped(){
        
        guard let friendUID = friendUserObject?.authUID, let friendName = friendUserObject?.displayName else{
            print("friendUIDオブジェクトからUIDとfriendNameを取得することに失敗しました。")
            return
        }
        if addFriendButton.isAdded == false{
            delegate?.showAddingFriendAlert(friendUID: friendUID, friendName: friendName, completion: {
                self.switchButtonState()
            })
        }else{
            delegate?.showUnfriendAlert(friendUID: friendUID, friendName: friendName, completion: {
                self.switchButtonState()
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

