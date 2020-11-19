//
//  FirstVC.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/18/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import FirebaseAuth

class FirstVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil{
                self.presentLoginVC()
            }
        }
        view.backgroundColor = .blue
        title = "FirstView"
        setViews()
    }
    
    private func setViews(){
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "text.bubble"), style: .done, target: self, action: #selector(chatViewButtonPressed))
        
    }

    @objc private func chatViewButtonPressed(){
    }
    
    func presentLoginVC(){
        
        let loginVC = LoginVC()
        let nav = UINavigationController(rootViewController: loginVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: false, completion: nil)
        
        
        
    }
    
}
