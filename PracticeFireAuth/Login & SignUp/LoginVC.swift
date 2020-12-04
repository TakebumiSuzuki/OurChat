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
        fbLoginButton.delegate = self
        
        setupViews()
        layoutViews()
        
//        if let token = AccessToken.current,
//            !token.isExpired {
//            // User is logged in, do work such as go to next view controller.
//        }
    }
    

    private func setupViews(){
        
        view.addSubview(fbLoginButton)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Up", style: .plain, target: self, action: #selector(signUpButtonTapped))
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc private func signUpButtonTapped(){
        
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    
    @objc private func loginButtonPressed(){
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            
            guard let self = self else{return}
            if error != nil{
                ServiceAlert.showSimpleAlert(vc: self, title: "Failed to log in", message: error!.localizedDescription); return
            }
            print("ログインに成功しました")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}


//MARK: - Facebookログイン処理

extension LoginVC: LoginButtonDelegate{
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if let error = error {print(error.localizedDescription); return}
        
        guard let token = result?.token?.tokenString else {print("FB認証サーバーからのtokenが得られませんでした"); return}
        
        print("FB認証サーバーでの認証に成功しました")

        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        
        Auth.auth().signIn(with: credential) { [weak self] (result, error) in //以前FBからサインインしたかどうかにかかわらずここでログイン
            
            guard let self = self else{return}
            if let error = error {print(error.localizedDescription); return}
            
            
            guard let result = result else {return}
            print("FBからのtokenを使いFirebaseAuthへのログインに成功しました")
            
            let userID = result.user.uid
            
            self.graphRequestFB(with: token, authUID: userID)
        }
    }
    
    
    private func graphRequestFB(with token: String, authUID: String){
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields":"email, first_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        
        facebookRequest.start { (connection, result, error) in
            
            guard let result = result as? [String: Any], error == nil else {
                print("FBのgraphRequestで情報を取得することに失敗しました。ログイン作業は中断します")
                return
            }
            
            //emailはnilにできないようにするのでguard let。
            guard let email = result["email"] as? String else{print("fbGraphRequestからのemail取得に失敗しました"); return}
            let firstName = result["first_name"] as? String ?? "New User" //登録時はFBのfirstNameをdisplayNameとして使う。
            let lastName = result["last_name"] as? String
            
            //取り敢えずemail,firstName,lastNameのみでまずは保存またはupdateする。
            User.saveUserToFireStore(authUID: authUID, email: email, displayName: firstName, pictureURL: nil, firstName: firstName, lastName: lastName, createdAt: Timestamp(), completion: { [weak self] error in
                
                guard let self = self else{return}
                if error != nil{print("ユーザー情報のFireStoreへの保存が失敗しました。ログイン作業は中断します\(error!)"); return}
                
                if Auth.auth().currentUser?.displayName == nil{
                    //ここでもしAuthの方にこのAuthUIDと紐づくdisplayNameがすでに登録されていなかったら、つまり新規登録者の場合。
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = firstName
                    changeRequest?.commitChanges(completion: { (error) in
                        if error != nil{print("displayNameのFirebaseAuthへの登録に失敗しました\(error!)"); return}
                    })
                }
                
                
                //基本情報をFirestoreに保存またはupdateできたので、次にfbGraphからの写真が存在する場合のみ、FireStorageに保存する。
                if let pictureKey = result["picture"] as? [String: Any],
                    let dataKey = pictureKey["data"] as? [String: Any],
                    let fbPictureDLURL = dataKey["url"] as? String{
                    
                    self.uploadFBPictureToFireStorage(url: fbPictureDLURL, authUID: authUID)
                    
                }else{
                    print("Facebookのprofile写真へのリンクは取得できませんでしたが、このまま登録作業を完了します。")
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    
    func uploadFBPictureToFireStorage(url: String, authUID: String){
        
        guard let url = URL(string: url) else {return}
        
        URLSession.shared.dataTask(with: url, completionHandler: { [weak self] data, response, error in
            
            guard let self = self else{return}
            if error != nil{print("Facebook profile pictureのダウンロード中にエラーです\(error!)"); return}
            
            guard let safeData = data, let profileImage = UIImage(data: safeData) else{
                print("ダウンロードしたFacebook写真データにエラーがあります。")
                return
            }
            
            guard let jpegData = profileImage.jpegData(compressionQuality: 0.3) else{return}
            
            FireStorageManager.uploadProfileImage(jpegData: jpegData) { (result) in
                
                switch result{
                case .success(let downloadURL):
                    print("FBPictureのFireStorageへのセーブが完了しました。")
                    Firestore.firestore().collection("users").document(authUID).setData(["pictureURL": downloadURL], merge: true) { (error) in
                        if error != nil{print("FireStorageにアップロードされた写真urlのセーブに失敗しました\(error!)"); return}
                    }
                    self.dismiss(animated: true, completion: nil)
                case .failure(_):
                    print("FBPictureのFireStorageへのセーブに失敗しましたがこのまま写真抜きでログインを完了させます")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }).resume()
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
