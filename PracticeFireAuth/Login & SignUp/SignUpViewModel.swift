//
//  SignUpViewModel.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 3/6/21.
//  Copyright © 2021 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class SignUpViewModel{
    
    let displayNamePublishSubject = PublishSubject<String>()
    let emailPublishSubject = PublishSubject<String>()
    let passwordPublishSubject = PublishSubject<String>()
    
    func isValid() -> Observable<Bool>{
        return Observable.combineLatest(
            displayNamePublishSubject.asObservable().startWith(""),
            emailPublishSubject.asObservable().startWith(""),
            passwordPublishSubject.asObservable().startWith(""))
            .map{ displayName, email, password in
                return displayName.count > 2 && email.count > 2 && password.count > 5
            }.startWith(false)
    }
}
