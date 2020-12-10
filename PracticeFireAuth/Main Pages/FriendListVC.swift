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
    
    private var quoteListener: ListenerRegistration?
    
    private var myUID = ""
    
    private var friends = [User]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let uid = Auth.auth().currentUser?.uid else{return}
        myUID = uid
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Friend List"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.magnifyingglass"), style: .plain, target: self, action: #selector(searchFriendButtonPressed))
        
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FriendListCell.self, forCellReuseIdentifier: "FriendListCell")
        
        setupViews()
        fetchFriends()
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if let quoteListener = self.quoteListener{
            quoteListener.remove()
            print("リスナ-removed")
        }
    }
    
    private func setupViews(){
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc private func searchFriendButtonPressed(){
        
        let vc = SearchFriendVC()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    
    //MARK: - FireStoreからfriend情報ダウンロード
    private func fetchFriends(){
        
        quoteListener = Firestore.firestore().collection("friendLists").document(myUID).addSnapshotListener {[weak self] (snapshot, error) in
            
            guard let self = self else{return}
            if error != nil{print("ユーザーの情報documentの取得に失敗しました。\(error!)"); return}
            
            self.friends.removeAll()
            let dispatchgroup = DispatchGroup()
            
            guard let keyValueDictionary = snapshot!.data() else{return}
            keyValueDictionary.forEach { (eachFriend) in
                
                dispatchgroup.enter()
                if let friendStatus = eachFriend.value as? String{    //友達のUID : "confirmed"のペアになっている
                    if friendStatus == "confirmed"{
                        let friendUID = eachFriend.key
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
            dispatchgroup.notify(queue: .main) {    //名前のアルファベット順に並べている。但し、日本語はどうなる！？？
                self.friends.sort(by: {(first: User, second: User) -> Bool in
                    first.displayName < second.displayName
                })
                print("fetch friend発動しています")
                self.tableView.reloadData()
            }
        }
    }
}


//MARK: - cellの中のfriend buttonを押した時のDelegate Methods
extension FriendListVC: FriendListCellDelegate{
    
    func showAddingFriendAlert(friendUID: String, friendName: String, completion: @escaping () -> Void){
        
        let alert1 = UIAlertAction(title: "Ok", style: .default) { [weak self](alert) in
            
            guard let self = self else {return}
            guard let myUID = Auth.auth().currentUser?.uid else{return}
            
            FireStoreManager.saveFriendInfoToFireStore(friendUID: friendUID, friendName: friendName, myUID: myUID) {
                
                ServiceAlert.showSimpleAlert(vc: self.presentingViewController!, title: "\(friendName) is your friend now!" , message: "Successfully added to your Friend List.")
                completion()
            }
        }
        let alert2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ServiceAlert.showMultipleSelectionAlert(vc: self, title: "Adding \(friendName) to your friend.", message: "ok?", actions: [alert1, alert2])
    }
    
    
    func showUnfriendAlert(friendUID: String, friendName: String, completion: @escaping () -> Void){
        
        let alert1 = UIAlertAction(title: "Ok", style: .default) { [weak self](alert) in
            
            guard let self = self else {return}
            guard let myUID = Auth.auth().currentUser?.uid else{return}
            
            FireStoreManager.deleteFriendInfofromFireStore(friendUID: friendUID, friendName: friendName, myUID: myUID) {
                
                ServiceAlert.showSimpleAlert(vc: self, title: "Unfriended with \(friendName)" , message: "Not friend anymore")
                completion()
            }
        }
        let alert2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ServiceAlert.showMultipleSelectionAlert(vc: self, title: "You are unfriending with \(friendName).", message: "Are you sure?", actions: [alert1, alert2])
    }
    
    
    
    //ここがchatRoomIDが作られる唯一の場所。これをchatRoomVCに引き継ぎ、そこでメッセージsendが押された時にFirestoreで保存される。
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


//MARK: - TableView Delegate Methods
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
        cell.addFriendButton.isAdded = true
        return cell
    }
    
}




