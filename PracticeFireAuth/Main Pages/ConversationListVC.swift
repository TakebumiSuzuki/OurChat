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
    
    private var quoteListener: ListenerRegistration?
    private var chatRooms: [ChatRoom] = []
    private var myUID: String = ""{
        didSet{
            guard let myDisplayName = Auth.auth().currentUser?.displayName
                else{print("Authから自分のdisplayNameを取得するのに失敗しました"); return}
            //currentUserメソッドは説明によると、synchronouslyにキャッシュされたUserの情報を返すという事なので、compハンドラーなどは存在しない。
            DispatchQueue.main.async {
                self.navigationItem.title = myDisplayName
            }
        }
    }
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.backgroundColor = .lightGray
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ConversationListCell.self, forCellReuseIdentifier: "conversationListCell")
        
        checkLoginStatus()
        setupViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //navigationController.pefersLargeTitlesとは異なり、こちらの方はviewWillAppear内じゃないとダメみたい。
        navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    
    private func checkLoginStatus(){
        
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else{return}
            
            if let user = user{
                print("StateDidChangeListenerが発動し自分のUIDのログイン状態が確認されました")
                self.myUID = user.uid
                self.fetchChatRooms()
                
            }else{
                print("StateDidChangeListenerが発動しログアウトが確認されました")
                self.tabBarController?.selectedIndex = 0
                self.presentLoginVC()
                
                if let quoteListener = self.quoteListener{
                    quoteListener.remove()
                }
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
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func fetchChatRooms(){
        
        quoteListener = Firestore.firestore().collection("chatRooms").whereField("members", arrayContains: myUID)
            .addSnapshotListener { [weak self] (snapshot, error) in
                
                guard let self = self else{return}
                if error != nil{print("chatRoom情報のダウンロードに失敗しました。\(error!)"); return}
                guard let snapshot = snapshot else{return}
                self.chatRooms.removeAll()
                
                snapshot.documents.forEach { (eachDocument) in
                    let dictionary = eachDocument.data()
                    let chatRoom = ChatRoom(dic: dictionary)
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationListCell", for: indexPath) as! ConversationListCell
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
        
        let chatRoomVC = ChatRoomVC()
        chatRoomVC.chatRoomID = chatRoom.chatRoomID
        chatRoomVC.friendUID = friendUID
        navigationController?.pushViewController(chatRoomVC, animated: true)
    }
    
}

