//
//  CustomTextField.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 3/5/21.
//  Copyright © 2021 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit

class CustomTextField: UITextField{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autocapitalizationType = .none
        autocorrectionType = .no
        layer.cornerRadius = 5
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.lightGray.cgColor
        backgroundColor = .secondarySystemBackground
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0)) //左端に隙間を作る
        leftViewMode = .always
        alpha = 0.9
        keyboardAppearance = .dark
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
