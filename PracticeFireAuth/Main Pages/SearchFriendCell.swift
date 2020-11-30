//
//  SearchFriendCell.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/30/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

protocol SearchFriendCellDelegate{
    func showAddingFriendAlert(friendUID: String, friendName: String)
}

class SearchFriendCell: UITableViewCell {
    
    var delegate: SearchFriendCellDelegate?
    
    var user: User?{
        didSet{
            if let url = user?.pictureURL{
                imagePicture.sd_setImage(with: URL(string: url), placeholderImage: UIImage(systemName: "cloud"))
            }
            nameLabel.text = user?.displayName
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
    
    lazy var addFriendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .link
        button.layer.cornerRadius = 7
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addFriendButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        addFriendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        addFriendButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    }
    
    @objc private func addFriendButtonTapped(){
        
        if let friendUID = user?.authUID, let friendName = user?.displayName{
            delegate?.showAddingFriendAlert(friendUID: friendUID, friendName: friendName)
            
        }
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

