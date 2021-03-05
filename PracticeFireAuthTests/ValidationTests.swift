//
//  ValidationTests.swift
//  PracticeFireAuthTests
//
//  Created by TAKEBUMI SUZUKI on 3/6/21.
//  Copyright © 2021 TAKEBUMI SUZUKI. All rights reserved.
//

import XCTest
@testable import PracticeFireAuth
import Firebase

class ValidationTests: XCTestCase {
    
    var sut: ValidationService!
    
    override func setUpWithError() throws {
        sut = ValidationService()
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func test_全てが正しい入力値の場合() throws{
        let displayName = "aaa"
        let email = "bbb@gmail.com"
        let password = "123456"
        do{
            print("ok")
            let tuple = try sut.validate(displayName: displayName, email: email, password: password)
            print("ko")
            XCTAssertEqual(tuple.displayName, "aaa")
            XCTAssertEqual(tuple.email, "bbb@gmail.com")
            XCTAssertEqual(tuple.password, "123456")
        }catch{
            return
        }
    }
    
    func test_displayNameとemailにwhiteSpaceが入っているが入力値は正しい時() throws{
        let displayName = " aaa   "
        let email = "   bbb@gmail.com "
        let password = "123456"
        do{
            print("ok")
            let tuple = try sut.validate(displayName: displayName, email: email, password: password)
            print("ko")
            XCTAssertEqual(tuple.displayName, "aaa")
            XCTAssertEqual(tuple.email, "bbb@gmail.com")
            XCTAssertEqual(tuple.password, "123456")
        }catch{
            return
        }
    }
    
    
    
    
    func test_displayNameが2文字の時() throws{
        let displayName = "aa"
        let email = ""
        let password = ""
        do{
            _ = try sut.validate(displayName: displayName, email: email, password: password)
        }catch{
            let error = error as? ValidationError
            XCTAssertEqual(error, ValidationError.displayNameLessThan3)
        }
    }

    func test_emailにcomなどが入ってない時(){
        let displayName = "aaa"
        let email = "ab@gmail"
        let password = ""
        do{
            _ = try sut.validate(displayName: displayName, email: email, password: password)
        }catch{
            let error = error as? ValidationError
            XCTAssertEqual(error, ValidationError.emailIsNotValid)
        }
        
    }
    
    func test_emailに＠が入ってない時(){
        let displayName = "aaa"
        let email = "abgmail.com"
        let password = ""
        do{
            _ = try sut.validate(displayName: displayName, email: email, password: password)
        }catch{
            let error = error as? ValidationError
            XCTAssertEqual(error, ValidationError.emailIsNotValid)
        }
    }
    
    func test_emailに＠の前の文字が入ってない時(){
        let displayName = "aaa"
        let email = "@gmail.com"
        let password = ""
        do{
            _ = try sut.validate(displayName: displayName, email: email, password: password)
        }catch{
            let error = error as? ValidationError
            XCTAssertEqual(error, ValidationError.emailIsNotValid)
        }
    }
    
    func test_passwordが5文字の時(){
        let displayName = "aaa"
        let email = "ab@gmail.com"
        let password = "12345"
        do{
            _ = try sut.validate(displayName: displayName, email: email, password: password)
        }catch{
            let error = error as? ValidationError
            XCTAssertEqual(error, ValidationError.passwordLessThan6)
        }
    }
    
}

