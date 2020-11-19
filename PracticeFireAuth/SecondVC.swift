//
//  SecondVC.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/18/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import FirebaseAuth

class SecondVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        title = "SecondView"
        setViews()
    }
    
    private func setViews(){
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.xmark"), style: .done, target: self, action: #selector(logOutButtonPressed))

    }
    
    @objc private func logOutButtonPressed(){
        
        try! Auth.auth().signOut()
        
        
    }
}
