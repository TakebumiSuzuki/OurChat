//
//  ConversationListVC.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/18/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage


class ConversationListVC: UIViewController {
    
    private var chatRooms: [ChatRoom] = []
    private var myUID: String = ""{
        didSet{
            guard let myDisplayName = Auth.auth().currentUser?.displayName else{print("Authから自分のdisplayNameを取得するのに失敗しました"); return}
            DispatchQueue.main.async {
                print("displayNameを取得したのでtitleに表示します")
                self.navigationItem.title = myDisplayName
            }
        }
    }
    
    private let tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("view1 did load")
        checkLoginStatus()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ConversationListCell.self, forCellReuseIdentifier: "myCell")
        view.backgroundColor = .white
        setupViews()
        
    }
    
    
    private func checkLoginStatus(){
        
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else{return}
            
            if let user = user{
                print("StateDidChangeListenerが発動し自分のUIDのログイン状態が確認されました")
                self.myUID = user.uid
                print("myUIDの方からもどりfetchChatRoom()実行に入ります。")
                self.fetchChatRooms()
            }else{
                print("StateDidChangeListenerが発動しログアウトが確認されました")
                self.tabBarController?.selectedIndex = 0
                self.presentLoginVC()
                return
            }
        }
    }
    
    private func presentLoginVC(){
        
        let loginVC = LoginVC()
        let nav = UINavigationController(rootViewController: loginVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    private func setupViews(){
        print("setupViews発動")
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.backgroundColor = .lightGray
    }

    private func fetchChatRooms(){
        print("myUIDは\(myUID)")
        Firestore.firestore().collection("chatRooms").whereField("members", arrayContains: myUID)
            .addSnapshotListener { [weak self] (snapshot, error) in
                print("fetchChatRoomsのlistner受信")
                guard let self = self else{return}
                if error != nil{print("chatRoom情報のダウンロードに失敗しました。\(error!)"); return}
                guard let snapshot = snapshot else{return}
                self.chatRooms.removeAll()
                
                print("ConversationListVCより。自分が関係するchatroomの数\(snapshot.count)")
                snapshot.documents.forEach { (eachDocument) in
                    let dictionary = eachDocument.data()
                    
                    var chatRoom = ChatRoom(dic: dictionary)
                    chatRoom.myUID = self.myUID
                    self.chatRooms.append(chatRoom)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
        }
    }
}


extension ConversationListVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! ConversationListCell
        let chatRoom = chatRooms[indexPath.row]
        cell.chatRoomObject = chatRoom
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chatRoom = chatRooms[indexPath.row]
        
        var friendUID = ""
        chatRoom.members.forEach { (memberUID) in
            if memberUID != myUID{
                friendUID = memberUID
            }
        }
        
        var chatRoomID = ""
        if myUID > friendUID{
            chatRoomID  = myUID + "_" + friendUID
        }else{
            chatRoomID = friendUID + "_" + myUID
        }
        
        let chatRoomVC = ChatRoomVC()
        chatRoomVC.chatRoomID = chatRoomID
        chatRoomVC.friendUID = friendUID
        navigationController?.pushViewController(chatRoomVC, animated: true)
    }
    
}

