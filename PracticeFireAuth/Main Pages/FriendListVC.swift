//
//  FriendListVC.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/29/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//
//FireStore側での名前順にした(おそらくアルファベット順)並び替え順は日本語ではどうなっているのか

import UIKit
import Firebase

class FriendListVC: UIViewController {
    
    private var myUID = ""
    
    private var friends = [User]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("view2 did load")
        guard let uid = Auth.auth().currentUser?.uid else{print("自分のユーザーUIDをAuthから取得するのに失敗しました"); return}
        myUID = uid
        
        view.backgroundColor = .lightGray
        navigationItem.title = "Friends"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.bubble"), style: .done, target: self, action: #selector(searchFriendButtonPressed))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FriendListCell.self, forCellReuseIdentifier: "FriendListCell")
        
        setupViews()
        fetchFriends()
     }
    
    private func setupViews(){
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    @objc private func searchFriendButtonPressed(){
        
        let vc = SearchFriendVC()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    private func fetchFriends(){
        
        let ref = Firestore.firestore().collection("friendLists").document(myUID)
        ref.addSnapshotListener {[weak self] (snapshot, error) in
            
            print("フレンドリストページのスナップショットリスナー作動")
            guard let self = self else{return}
            if error != nil{print("ユーザーの情報documentの取得に失敗しました。\(error!)"); return}
            
            self.friends.removeAll()
            let dispatchgroup = DispatchGroup()
            
            if let keyValueDictionary = snapshot!.data(){
                keyValueDictionary.forEach { (eachFriendRequest) in
                    
                    dispatchgroup.enter()
                    if let status = eachFriendRequest.value as? String{  //友達のUID : "confirmed"のペアになっている
                        if status == "confirmed"{
                            let friendUID = eachFriendRequest.key
                            User.createUserObjectFromUID(authUID: friendUID) { (result) in
                                
                                switch result{
                                case .success(let userObject):
                                    self.friends.append(userObject)
                                    dispatchgroup.leave()
                                case .failure(_):
                                    print("自分の友達リストの中のあるユーザーのオブジェクトを彼のuidから作成することに失敗しました。")
                                    dispatchgroup.leave()
                                }
                            }
                        }
                    }
                }
                dispatchgroup.notify(queue: .main) {
                    self.friends.sort(by: {(first: User, second: User) -> Bool in
                        first.displayName < second.displayName
                    })
                    print("スナップショットリスナー後のテーブルビューリロードが発動しました。")
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("view2 will Appear")
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("view2 will Disappear")
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("view2 did Disappear")
    }
}


extension FriendListVC: FriendListCellDelegate{ //チャットルームオープンと、セルを長押しした時の友達消去コマンド
    
    func PushChatRoom(friendUserObject: User) {
        
        var chatRoomID = ""
        let friendUID = friendUserObject.authUID
        if myUID > friendUID{
            chatRoomID  = myUID + "_" + friendUID
        }else{
            chatRoomID = friendUID + "_" + myUID
        }
        
        let chatRoomVC = ChatRoomVC()
        chatRoomVC.chatRoomID = chatRoomID
        chatRoomVC.friendUID = friendUID
        self.navigationController?.pushViewController(chatRoomVC, animated: true)
    }
    
    
    func cellLongPressedGesture(friendUID: String, friendName: String) {
        
        let action1 = UIAlertAction(title: "Delete", style: .default) { (action) in
            
            Firestore.firestore().collection("friendLists").document(self.myUID).updateData([friendUID : FieldValue.delete()]) { (error) in
                if error != nil{print("FireStore内の自分のフレンドドキュメント内の、FirendUIDフィールド消去に失敗しました。"); return}
            }
            Firestore.firestore().collection("friendLists").document(friendUID).updateData([self.myUID : FieldValue.delete()]) { (error) in
                if error != nil{print("FireStore内の友達のドキュメント内の、自分UIDフィールドの消去に失敗しました。"); return}
            }
        }
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ServiceAlert.showMultipleSelectionAlert(vc: self, title: "cancel friendship", message: "Are you really want to unfriend with \(friendName)?", actions: [action1,action2])
    }
    
}


extension FriendListVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendListCell", for: indexPath) as! FriendListCell
        cell.friendUserObject = friends[indexPath.row]
        cell.delegate = self
        return cell
    }
    
}




