//
//  SettingViewModel.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 3/7/21.
//  Copyright © 2021 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingViewModel{
    
    
    let displayName = PublishSubject<String>()
    let email = PublishSubject<String>()
    let status = PublishSubject<String>()
    let imageURL = PublishSubject<String>()
    let canSave: Observable<Bool>
    
    
    var myUser: User!
    init(myUser: User) {
        self.myUser = myUser
        
        canSave = Observable.combineLatest(displayName.asObservable().startWith(myUser.displayName),
                                           email.asObservable().startWith(myUser.email),
                                           status.asObservable().startWith(myUser.status ?? "")) {(displayName, email, status) in
            
            if displayName != myUser.displayName || email != myUser.email || status != myUser.status{
                return true
            }
            return false
        }
    }
    
    
    
}
