//
//  AddFriendVC.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/30/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

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
        
        return table
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(SearchFriendCell.self, forCellReuseIdentifier: "SearchFriendCell")
        view.backgroundColor = .white
        
        setupViews()
    }
    
    func setupViews(){
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
    }
    
    
    private func searchStarted(query: String){
        
        let fieldNameToSearch = query.isValidEmail ? "email" : "displayName"
        
        Firestore.firestore().collection("users")
            .whereField(fieldNameToSearch, isEqualTo: query)
            .order(by: "createdAt", descending: true)
            .getDocuments { (snapshot, error) in
                
                if error != nil{print("Friend検索中にエラーです。\(error!)"); return}
                
                let dispatchGroup = DispatchGroup()
                let resultDocs = snapshot!.documents
                for resultDoc in resultDocs{
                    dispatchGroup.enter()
                    let friendUID = resultDoc.documentID
                    User.createUserObjectFromUID(authUID: friendUID) { [weak self] (result) in
                        
                        guard let self = self else{return}
                        switch result{
                        case .success(let user):
                            self.foundUsers.append(user)
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
                        ServiceAlert.showSimpleAlert(vc: self, title: "There is no result.", message: "Check out your spell once again")
                    }
                }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.endEditing(true)
    }

}

extension SearchFriendVC: UISearchBarDelegate{
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {return}
        searchBar.resignFirstResponder()
        searchStarted(query: text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange: String){
        if searchBar.text?.count ?? 0 >= 1{
            foundUsers = []
            tableView.reloadData()
            
        }
    }
}


extension SearchFriendVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
        cell.user = foundUsers[indexPath.row]
        cell.delegate = self
        return cell
        
    }
}


extension SearchFriendVC: SearchFriendCellDelegate{
    
    func showAddingFriendAlert(friendUID: String, friendName: String) {
        
        let alert1 = UIAlertAction(title: "Ok", style: .default) { [weak self](alert) in
            
            guard let self = self else {return}
            if let myUID = Auth.auth().currentUser?.uid{
                
                if friendUID == myUID{
                    ServiceAlert.showSimpleAlert(vc: self, title: "You are you!!", message: "")
                    return
                }
                self.saveFriendInfoToFireStore(friendUID: friendUID, friendName: friendName, myUID: myUID)
            }
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
            ServiceAlert.showSimpleAlert(vc: self.presentingViewController!, title: "You and \(friendName) are friends now!" , message: "Successfully added to your Friend List.")
        }
        
    }
    
    
}


