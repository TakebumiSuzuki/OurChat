//
//  AccountTextField.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 3/7/21.
//  Copyright © 2021 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit

class AccountTextField: UITextField{
    
    let padding = UIEdgeInsets(top: 0, left: 9, bottom: 0, right: 9)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 11
        font = UIFont.systemFont(ofSize: 18, weight: .regular)
        textColor = .white
        tintColor = .white
        autocapitalizationType = .none
        autocorrectionType = .no
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


