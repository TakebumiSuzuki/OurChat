//
//  SettingVC.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/18/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class SettingVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white
        title = "Account"
        setViews()
    }
    
    private func setViews(){
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOutButtonPressed))
    }
    
    @objc private func logOutButtonPressed(){
        
        let action1 = UIAlertAction(title: "OK", style: .default) { (action) in
            do{
                try Auth.auth().signOut()
            }catch{
                print("failed to log out from Firebase Auth sign in")
            }
            
            FBSDKLoginKit.LoginManager().logOut()
        }
        
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ServiceAlert.showMultipleSelectionAlert(vc: self, title: "Logging out", message: "Would you really like to log out?", actions: [action1, action2])
    }
    
}
