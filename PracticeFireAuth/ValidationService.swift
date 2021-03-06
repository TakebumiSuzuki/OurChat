//
//  ValidationService.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 3/6/21.
//  Copyright © 2021 TAKEBUMI SUZUKI. All rights reserved.
//

import Foundation

enum ValidationError: String, Equatable, Error {
    case displayNameLessThan3 = "displayName needs to have more than 3 charactors."
    case emailIsNotValid = "email is not in valid format."
    case passwordLessThan6 = "password needs to have more than 6 charactors."
}

struct ValidationService{
    
    func validate(displayName: String, email: String, password: String) throws -> (displayName: String, email: String, password: String) {
        
        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        if displayName.count < 3{
            throw ValidationError.displayNameLessThan3
        }
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedEmail.isValidEmail{
            throw ValidationError.emailIsNotValid
        }
        
        if password.count < 6{
            throw ValidationError.passwordLessThan6
        }
        
        return (displayName: trimmedDisplayName, email: trimmedEmail, password: password)
        
    }

}
