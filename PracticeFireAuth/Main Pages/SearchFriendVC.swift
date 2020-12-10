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
    
    private var quoteListener: ListenerRegistration?
    
    private var foundUsers: [User] = []
    //private var requestingUsers: [User] = []
    
    private var myFriendListDic = ["" : ""]  //viewDidLoadでFireStoreへのアクセスが行われ、友達辞書がここに代入される
    
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
        fetchMyFriendListDic()  //検索した相手が、すでに自分のフレンドリストに入っているかどうかを調べるために必要
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
    
    private func fetchMyFriendListDic(){ //このリストはviewDiDLoadで実行され、ユーザーが検索をかけた時のdequeueの際に、各cellに渡される。
        
        guard let myUID = Auth.auth().currentUser?.uid else{return}
        quoteListener = Firestore.firestore().collection("friendLists").document(myUID).addSnapshotListener { [weak self] (snapshot, error) in
            print("dictionary updated")
            guard let self = self else{return}
            if error != nil{print("自分のfriend listドキュメント取得に失敗しました"); return}
            guard let snapshot = snapshot, let dictionary = snapshot.data() as? [String : String] else{return}
            
            self.myFriendListDic = dictionary
        }
    }
    
    private func searchBegin(query: String){  //emailまたはdisplayNameで全Userを検索して、createdAtの新しい順に並べる。
        
        let emailOrDisplayName = query.isValidEmail ? "email" : "displayName"
        
        Firestore.firestore().collection("users")
            .whereField(emailOrDisplayName, isEqualTo: query)
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self](snapshot, error) in
                
                guard let self = self else{return}
                if error != nil{print("Friend検索中にエラーです。\(error!)"); return}
                
                let dispatchGroup = DispatchGroup()
                guard let snapshot = snapshot else{return}
                let resultDocs = snapshot.documents
                self.foundUsers.removeAll()
                
                for singleDocument in resultDocs{
                    dispatchGroup.enter()
                    let friendUID = singleDocument.documentID //data()とやる代わりにこうするとパス名を取得できる
                    if friendUID == Auth.auth().currentUser?.uid{  //自分自身を除外する
                        dispatchGroup.leave()
                        continue   //これがないと、このまま下に処理が続いていってdispatchGroup.leave()が重複されてエラーになってしまうよう。
                    }
                    print("searchBegin")
                    User.createUserObjectFromUID(authUID: friendUID) { (result) in
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


//MARK: - SearchBar Delegate Methods サーチバーの各種設定
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


//MARK: - TableView Delegate Methods
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.foundUsers.count == 0{
            return nil
        }else{
            return "Search Result"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foundUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchFriendCell", for: indexPath) as! SearchFriendCell
        cell.friendUserObject = foundUsers[indexPath.row]
        cell.myFriendListDic = myFriendListDic
        cell.delegate = self
        return cell
    }
}


//MARK: - Cell Delegate 友達追加ボタンが押された時 Cellの方からDelegateでトリガーされる。
extension SearchFriendVC: SearchFriendCellDelegate{  //友達を追加する
    
    func showAddingFriendAlert(friendUID: String, friendName: String, completion: @escaping() -> Void) {
        
        let alert1 = UIAlertAction(title: "Ok", style: .default) { [weak self](alert) in
            
            guard let self = self else {return}
            guard let myUID = Auth.auth().currentUser?.uid else{return}
            
            FireStoreManager.saveFriendInfoToFireStore(friendUID: friendUID, friendName: friendName, myUID: myUID) {
                guard let text = self.searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {return}
                
                self.searchBegin(query: text)
                
                ServiceAlert.showSimpleAlert(vc: self, title: "\(friendName) is your friend now!" , message: "Successfully added to your Friend List.")
                completion()
            }
        }
        
        let alert2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ServiceAlert.showMultipleSelectionAlert(vc: self, title: "Adding \(friendName) to your friend.", message: "ok?", actions: [alert1, alert2])
    }
    
    
    
    func showUnfriendAlert(friendUID: String, friendName: String, completion: @escaping() -> Void){
        
        let alert1 = UIAlertAction(title: "Ok", style: .default) { [weak self](alert) in
            
            guard let self = self else {return}
            guard let myUID = Auth.auth().currentUser?.uid else{return}
            
            FireStoreManager.deleteFriendInfofromFireStore(friendUID: friendUID, friendName: friendName, myUID: myUID) {
                guard let text = self.searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {return}
                
                self.searchBegin(query: text)
                
                ServiceAlert.showSimpleAlert(vc: self, title: "Unfriended with \(friendName)" , message: "Not friend anymore")
                completion()
                
            }
        }
        
        let alert2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ServiceAlert.showMultipleSelectionAlert(vc: self, title: "You are unfriending with \(friendName).", message: "Are you sure?", actions: [alert1, alert2])
    }
    
    
    
    
}


