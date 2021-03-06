//
//  AccountButton.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 3/7/21.
//  Copyright © 2021 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit

class AccountButton: UIButton{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setTitleColor(.white, for: .normal)
        isEnabled = false
        backgroundColor = .lightGray
        layer.cornerRadius = 3
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
