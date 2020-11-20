//
//  LoginVC.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/18/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginVC: UIViewController {

    
    let fbLoginButton:FBLoginButton = {
        let button = FBLoginButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    let emailTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 8
        field.layer.borderWidth = 1.5
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "enter email for log in"
        field.backgroundColor = .secondarySystemBackground
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    let passwordTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 8
        field.layer.borderWidth = 1.5
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "enter password for sign up"
        field.backgroundColor = .secondarySystemBackground
        field.isSecureTextEntry = true
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    let loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Login"
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        setupViews()
        layoutViews()
        
        if let token = AccessToken.current,
            !token.isExpired {
            // User is logged in, do work such as go to next view controller.
        }
    }
    

    private func setupViews(){
        
        view.addSubview(fbLoginButton)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "lock.open"), style: .plain, target: self, action: #selector(signUpButtonTapped))
    }

    private func layoutViews(){
        
        let margins = view.layoutMarginsGuide
        
        fbLoginButton.topAnchor.constraint(equalTo: margins.topAnchor, constant: 200).isActive = true
        fbLoginButton.bottomAnchor.constraint(equalTo: margins.topAnchor, constant: 240).isActive = true
        fbLoginButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 20).isActive = true
        fbLoginButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -20).isActive = true
        
        emailTextField.topAnchor.constraint(equalTo: fbLoginButton.bottomAnchor, constant: 40).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: fbLoginButton.leadingAnchor).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: fbLoginButton.trailingAnchor).isActive = true
        
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: fbLoginButton.leadingAnchor).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: fbLoginButton.trailingAnchor).isActive = true
        
        loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        loginButton.widthAnchor.constraint(equalTo: fbLoginButton.widthAnchor, multiplier: 0.7).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
    }
    
    
    @objc private func signUpButtonTapped(){
        
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc private func loginButtonPressed(){
        
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            
            guard let self = self else{return}
            if error != nil{
                ServiceAlert.showSimpleAlert(vc: self, title: "Failed to log in", message: error!.localizedDescription)
            }
            
            guard let result = result else{return}
            print("successfully logged in")
            let userID = result.user.uid
            
            self.createUserObject(userID: userID, pictureURL: "testURL")
        }
        
    }
    private func createUserObject(userID: String, pictureURL: String){
        
        Firestore.firestore().collection("users").document(userID).getDocument { [weak self] (snapshot, error) in
            
            guard let self = self else {return}
            if let error = error{
                print("Failed to fetch user info from Firestore. \(error.localizedDescription)" ) ; return
            }
            
            guard let data = snapshot?.data() else {return}
            
            let user = User.init(dic: data, userID: userID, pictureURL: pictureURL)
            
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    
}


//MARK: - UITextFieldDelegate Methods

extension LoginVC: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField{
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            loginButtonPressed()
        default:
            break
        }
        return true
    }
    
}
