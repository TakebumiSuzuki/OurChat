//
//  LoginViewModel.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 3/6/21.
//  Copyright © 2021 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewModel{
    
    let emailPublishSubject = PublishSubject<String>()
    let passwordPublishSubject = PublishSubject<String>()
    
    func isValid() -> Observable<Bool>{
        
        return Observable.combineLatest(
            emailPublishSubject.asObservable().startWith(""),
            passwordPublishSubject.asObservable().startWith(""))
            .map{ email, password in
                return email.count > 2 && password.count > 5
            }.startWith(false)
        
    }
}
