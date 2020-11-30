//
//  ConversationListVC.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/18/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import Firebase

struct ChatRoom{
    let members: [String]
    let chatRoomID: String
    let createdAt: Timestamp
    let latestMessage: Message
}

class ConversationListVC: UIViewController {
    
    var chatRooms: [ChatRoom] = []
    var myUID: String = ""
    
    let table: UITableView = {
        let table = UITableView()
        
        return table
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view1 did load")
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            print("addStateDidChangeListener got triggered")
            guard let self = self else{return}
            if let user = user{
                self.myUID = user.uid
                self.navigationItem.title = user.displayName
            }else{
                print("user has just logged out")
                self.tabBarController?.selectedIndex = 0
                self.presentLoginVC()
                return
            }
        }
        
        table.delegate = self
        table.dataSource = self
        table.register(ConversationListCell.self, forCellReuseIdentifier: "myCell")
        
        view.backgroundColor = .blue
        
        setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view1 will Appear")
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("view1 will Disappear")
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("view1 did Disappear")
    }
    
    private func setViews(){
        
        view.addSubview(table)
        table.frame = view.bounds
        table.backgroundColor = .lightGray
        
        
    }

    
    
    func presentLoginVC(){
        
        let loginVC = LoginVC()
        let nav = UINavigationController(rootViewController: loginVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
        
    }
    
}


extension ConversationListVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
//        return chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! ConversationListCell
//        let chatRoom = chatRooms[indexPath.row]
//        cell.setContents(chatRoom: chatRoom)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
        let chatRoomVC = ChatRoomVC()
        self.navigationController?.pushViewController(chatRoomVC, animated: true)
    }
    
    
    
}

