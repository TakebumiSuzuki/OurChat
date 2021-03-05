//
//  ServiceAlert.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/20/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit

class ServiceAlert{
    
    class func showSimpleAlert(vc:UIViewController, title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "ok", style: .cancel, handler: nil)
        alert.addAction(action)
        vc.present(alert, animated: true)
    }
    
    
    class func showMultipleSelectionAlert(vc: UIViewController, title: String, message: String, actions: [UIAlertAction]){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for action in actions{
            alert.addAction(action)
        }
        vc.present(alert, animated: true)
    }
    
}

extension UIAlertController {   //UIAlertControllerのconstraintエラーがconsoleに表示されるバグを除去するための処置。
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        pruneNegativeWidthConstraints()
    }

    private func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}




