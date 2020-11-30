//
//  FriendListVC.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/29/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import Firebase

class FriendListVC: UIViewController {

    private var friends = [User]()
    
    private let table: UITableView = {
        let table = UITableView()
        
        return table
    }()
    
    private var authUID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightGray
        navigationItem.title = "Friends"
        authUID = Auth.auth().currentUser?.uid
        
        table.delegate = self
        table.dataSource = self
        table.register(FriendListCell.self, forCellReuseIdentifier: "FriendListCell")
        print("view2 did load")
        setupViews()
        fetchFriends()
        
     }
    
    private func setupViews(){
        
        view.addSubview(table)
        table.frame = view.bounds
        
    }
    
    
    private func fetchFriends(){
        
        guard let authUID = authUID else{print("UIDの取得に失敗しました"); return}
        
        let ref = Firestore.firestore().collection("friendLists").document(authUID)
        ref.addSnapshotListener {[weak self] (snapshot, error) in
            
            guard let self = self else{return}
            if error != nil{print("ユーザーの情報documentの取得に失敗しました"); return}
            
            let dispatchgroup = DispatchGroup()
            if let documentDic = snapshot!.data(){
                documentDic.forEach { (eachFriendRequest) in
                    
                    dispatchgroup.enter()
                    if let status = eachFriendRequest.value as? String{
                        if status == "confirmed"{
                            let friendUID = eachFriendRequest.key
                            User.createUserObjectFromUID(authUID: friendUID) { (result) in
                                
                                switch result{
                                case .success(let userObject):
                                    self.friends.append(userObject)
                                    dispatchgroup.leave()
                                case .failure(_):
                                    print("failed to create User object from friend's UID")
                                    dispatchgroup.leave()
                                    break
                                }
                            }
                        }
                    }
                }
                dispatchgroup.notify(queue: .main) {
                    self.friends.sort(by: {(first: User, second: User) -> Bool in
                        first.displayName > second.displayName
                    })
                    
                    self.table.reloadData()
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

extension FriendListVC: UITableViewDelegate, UITableViewDataSource, DeleteFriendAlertDelegate{
    
    func cellLongPressedGesture(userUID: String) {
        
        guard let authUID = authUID else{print("UIDの取得に失敗しました"); return}
        let action1 = UIAlertAction(title: "Delete", style: .default) { (action) in
            Firestore.firestore().collection("friendLists").document(authUID).updateData([userUID : FieldValue.delete()]) { (error) in
                if error != nil{print("FireStore内のFirendのUID消去に失敗しました。"); return}
            }
        }
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ServiceAlert.showMultipleSelectionAlert(vc: self, title: "calncel friendship", message: "Would you like to delete your friend?", actions: [action1,action2])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "FriendListCell", for: indexPath) as! FriendListCell
        cell.user = friends[indexPath.row]
        cell.delegate = self
        print(friends[indexPath.row])
        return cell
    }
    
}




