//
//  AccountUILabel.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 3/7/21.
//  Copyright © 2021 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit

class AccountUILabel: UILabel{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
