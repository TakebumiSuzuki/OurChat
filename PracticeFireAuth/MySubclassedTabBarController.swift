//
//  MySubclassedTabBarController.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 12/6/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//
//https://stackoverflow.com/questions/44346280/how-to-animate-tab-bar-tab-switch-with-a-crossdissolve-slide-transition/57116930#57116930


import UIKit
import Firebase

class MySubclassedTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        
        
    }
}

extension MySubclassedTabBarController: UITabBarControllerDelegate  {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
          return false // Make sure you want this as false
        }

        if fromView != toView {
          UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
        }

        return true
    }
}
