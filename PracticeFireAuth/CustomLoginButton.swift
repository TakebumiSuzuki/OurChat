//
//  CustomLoginButton.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 3/5/21.
//  Copyright © 2021 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit

class CustomLoginButton: UIButton{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .link
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = 5
        alpha = 0.85
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
