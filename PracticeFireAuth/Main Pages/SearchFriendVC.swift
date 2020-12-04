//
//  AddFriendVC.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/30/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//
//キャピタライゼーションで大文字小文字の検索論理はfirebaseでどうなっているのか?区別して検索するのか
//すでに友達を検索してaddボタンを押した時に上書きされるので問題はないが、一応のバリデーションは必要だろう。

import UIKit
import Firebase

class SearchFriendVC: UIViewController{
    
    private var foundUsers: [User] = []
    //private var requestingUsers: [User] = []
    
    private let searchBar: UISearchBar = {
       let bar = UISearchBar()
        bar.placeholder = "search with email or name"
        bar.becomeFirstResponder()
        bar.showsCancelButton = true
        bar.autocapitalizationType = .none
        return bar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(SearchFriendCell.self, forCellReuseIdentifier: "SearchFriendCell")
        navigationItem.titleView = searchBar
        view.backgroundColor = .white
        
        setupViews()
    }
    
    private func setupViews(){
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    private func searchBegin(query: String){  //emailまたはdisplayNameで全Userを検索して、createdAtの新しい順に並べる。
        
        let emailOrDisplayName = query.isValidEmail ? "email" : "displayName"
        
        Firestore.firestore().collection("users")
            .whereField(emailOrDisplayName, isEqualTo: query)
            .order(by: "createdAt", descending: true)
            .getDocuments { (snapshot, error) in
                
                if error != nil{print("Friend検索中にエラーです。\(error!)"); return}
                
                let dispatchGroup = DispatchGroup()
                let resultDocs = snapshot!.documents
                for singleDocument in resultDocs{
                    dispatchGroup.enter()
                    let friendUID = singleDocument.documentID
                    User.createUserObjectFromUID(authUID: friendUID) { [weak self] (result) in
                        
                        guard let self = self else{return}
                        switch result{
                        case .success(let userObject):
                            self.foundUsers.append(userObject)
                            dispatchGroup.leave()
                        case .failure(_):
                            print("FriendのUIDからUserオブジェクトを作るのに失敗しました")
                            dispatchGroup.leave()
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    self.tableView.reloadData()
                    if self.foundUsers.isEmpty{
                        ServiceAlert.showSimpleAlert(vc: self, title: "There is no result.", message: "Check out spell once again")
                    }
                }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { //全く抗力を発揮していない。なぜ？
        searchBar.endEditing(true)
    }

}

extension SearchFriendVC: UISearchBarDelegate{
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        dismiss(animated: true, completion: nil)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {return}
        searchBar.resignFirstResponder()
        searchBegin(query: text)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange: String){
        if searchBar.text?.count ?? 0 >= 1{
            foundUsers = []
            tableView.reloadData()
        }
    }
}


extension SearchFriendVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Search Result"
        }else{
            return "Friend requests"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return foundUsers.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchFriendCell", for: indexPath) as! SearchFriendCell
        cell.friendUserObject = foundUsers[indexPath.row]
        cell.delegate = self
        return cell
    }
}


extension SearchFriendVC: SearchFriendCellDelegate{  //友達を追加する
    
    func showAddingFriendAlert(friendUID: String, friendName: String) {
        
        let alert1 = UIAlertAction(title: "Ok", style: .default) { [weak self](alert) in
            
            guard let self = self else {return}
            guard let myUID = Auth.auth().currentUser?.uid else{print("自分のUIDの取得に失敗しました");return}
            
            if friendUID == myUID{
                ServiceAlert.showSimpleAlert(vc: self, title: "You can't friend with your self!!", message: "")
                return
            }
            self.saveFriendInfoToFireStore(friendUID: friendUID, friendName: friendName, myUID: myUID)
            
        }
        
        let alert2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ServiceAlert.showMultipleSelectionAlert(vc: self, title: "Adding \(friendName) to your friend.", message: "ok?", actions: [alert1, alert2])
    }
    
    
    func saveFriendInfoToFireStore(friendUID: String, friendName: String, myUID: String) {
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        Firestore.firestore().collection("friendLists").document(friendUID).setData([myUID : "confirmed"], merge: true )
        Firestore.firestore().collection("friendLists").document(myUID).setData([friendUID : "confirmed"], merge: true)
        dispatchGroup.leave()
        
        dispatchGroup.notify(queue: .main) {
            self.dismiss(animated: true, completion: nil)
            ServiceAlert.showSimpleAlert(vc: self.presentingViewController!, title: "\(friendName) is your friend now!" , message: "Successfully added to your Friend List.")
        }
    }
    
    
}


