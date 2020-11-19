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




