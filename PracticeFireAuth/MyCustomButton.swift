//
//  FriendAddButton.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 12/7/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit

class MyCustomButton: UIButton{
    
    
    override var isHighlighted: Bool { //isHighlightedはUIButtonクラスのプロパティで、ボタンが押されている間のみfalseを連発する。
        didSet {  //もしボタンが押されていたらその間はずっとtrueなので、つまりはalphaが0.3になる
            self.isHighlighted ? (self.addFriendLabel.alpha = 0.3) : (self.addFriendLabel.alpha = 1.0)
        }
    }
    
    var isAdded: Bool = false{
        didSet{
            if isAdded == true{  //もし友達に加えたなら、チェックマークを入れて"friend"表記に。
                self.checkmarkImage.image = UIImage(systemName: "checkmark")
                self.addFriendLabel.text = " Friend"
                self.backgroundColor = .lightGray
            }else{  //もしunfriendしたならば、"Add"表記にする
                self.checkmarkImage.image = UIImage(systemName: "")
                self.addFriendLabel.text = "Add"
                self.backgroundColor = .blue
            }
        }
    }
    func switchButtonState(){  //このボタンが重要で、ボタンの表記を変えるす切り替えスイッチ。
        isAdded = isAdded ? false : true
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
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(checkmarkImage)
        addSubview(addFriendLabel)
        clipsToBounds = true
        layer.cornerRadius = 10
        backgroundColor = .blue
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        checkmarkImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        checkmarkImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 9).isActive = true
        checkmarkImage.widthAnchor.constraint(equalToConstant: 20).isActive = true
        checkmarkImage.widthAnchor.constraint(equalTo: checkmarkImage.heightAnchor).isActive = true
        
        addFriendLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        addFriendLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
