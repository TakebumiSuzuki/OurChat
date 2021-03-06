//
//  AccountLine.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 3/7/21.
//  Copyright © 2021 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit

class AccountLine: UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
