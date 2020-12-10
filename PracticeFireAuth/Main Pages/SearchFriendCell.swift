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
    
    var friendUserObject: User?{   //placeholderのイメージが必要かと。この変数としたのmyFriendListDicはcellのインスタンス化の後に代入される。
        didSet{
            if let url = friendUserObject?.pictureURL{
                imagePicture.sd_setImage(with: URL(string: url), placeholderImage: nil)
            }
            nameLabel.text = friendUserObject?.displayName
        }
    }
    
    var myFriendListDic = ["" : ""]{   //VCのtableViewがdequeueした直後、まず上のfriendUserObjectが、それに引き続きこれが各cellに代入される。
        didSet{
            let friendUID = friendUserObject?.authUID
            for keyValuePair in myFriendListDic{
                
                if keyValuePair == (key: friendUID, value: "confirmed"){   //すでに友達に登録されている場合。それ以外は初期値のままfalseという事。
                    addFriendButton.isAdded = true
                    return
                }
            }
            addFriendButton.isAdded = false
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
        label.font = .systemFont(ofSize: 30, weight: .light)
        return label
    }()
    
    private var addFriendButton: MyCustomButton = {
        let button = MyCustomButton(frame: .zero)  //constraintをつけているので、.zeroで問題ない
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
        
        contentView.frame = self.bounds  //この設定で回転させたといも中央で分割されない。このままで良いかと。
        
        imagePicture.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 35).isActive = true
        imagePicture.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imagePicture.heightAnchor.constraint(equalTo: imagePicture.widthAnchor).isActive = true
        imagePicture.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: imagePicture.trailingAnchor, constant: 25).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        addFriendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -35).isActive = true
        addFriendButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        addFriendButton.widthAnchor.constraint(equalToConstant: 110).isActive = true
        addFriendButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    
    @objc private func addFriendButtonTapped(){
        
        guard let friendUID = friendUserObject?.authUID, let friendName = friendUserObject?.displayName else{
            print("friendUIDオブジェクトからUIDとfriendNameを取得することに失敗しました。")
            return
        }
        if addFriendButton.isAdded == false{   //まだ友達でないなら
            delegate?.showAddingFriendAlert(friendUID: friendUID, friendName: friendName, completion: {
                self.switchButtonState()  //ボタンの表示を変える。
            })
        }else{     //すでに友達なら
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
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

