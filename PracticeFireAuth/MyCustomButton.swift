//
//  FriendAddButton.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 12/7/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit

class MyCustomButton: UIButton{
   
    var isAdded: Bool = false{
        didSet{
            if isAdded == true{
                self.checkmarkImage.image = UIImage(systemName: "checkmark")
                self.addFriendLabel.text = "Friend"
                self.backgroundColor = .lightGray
            }else{
                self.checkmarkImage.image = UIImage(systemName: "")
                self.addFriendLabel.text = "Add"
                self.backgroundColor = .blue
            }
        }
    }
    private let checkmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "")
        imageView.tintColor = .green
        return imageView
    }()
    private let addFriendLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Add"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(checkmarkImage)
        addSubview(addFriendLabel)
        clipsToBounds = true
        layer.cornerRadius = 9
        backgroundColor = .blue
    }
    
    func switchButtonState(){
        isAdded = isAdded ? false : true
        print(isAdded)
    }
    
    func addButtonTouchDown(){
//        self.alpha = 0.3
//        print("test")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        checkmarkImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        checkmarkImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 7).isActive = true
        checkmarkImage.widthAnchor.constraint(equalToConstant: 20).isActive = true
        checkmarkImage.widthAnchor.constraint(equalTo: checkmarkImage.heightAnchor).isActive = true
        
        addFriendLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        addFriendLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
