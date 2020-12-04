//
//  SignUpVC.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/18/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController {
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .gray
        imageView.image = UIImage(systemName: "person")
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    lazy var displayNameField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 8
        field.layer.borderWidth = 1.5
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "enter your display name"
        field.backgroundColor = .secondarySystemBackground
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    
    lazy var emailTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 8
        field.layer.borderWidth = 1.5
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "enter email for sign up"
        field.backgroundColor = .secondarySystemBackground
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    
    lazy var passwordTextField: UITextField = {
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
    
    lazy var registerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "sign up"
        view.backgroundColor = .white
        
        displayNameField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        setUpViews()
        layoutViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    private func setUpViews(){
        view.addSubview(profileImageView)
        view.addSubview(displayNameField)
        view.addSubview(emailTextField)
        view.addSubview(registerButton)
        view.addSubview(passwordTextField)
        
    }
    
    private func layoutViews(){
        
        let margins = view.layoutMarginsGuide
        profileImageView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 50).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.25).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        
        displayNameField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 30).isActive = true
        displayNameField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        displayNameField.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 20).isActive = true
        displayNameField.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -20).isActive = true
        
        emailTextField.topAnchor.constraint(equalTo: displayNameField.bottomAnchor, constant: 20).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: displayNameField.leadingAnchor).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: displayNameField.trailingAnchor).isActive = true
        
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: displayNameField.leadingAnchor).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: displayNameField.trailingAnchor).isActive = true
        
        registerButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30).isActive = true
        registerButton.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        registerButton.widthAnchor.constraint(equalTo: displayNameField.widthAnchor, multiplier: 0.6).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2.0  //onstraintsのwidthの計算後になるように、ここに書く。
        
        profileImageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        profileImageView.addGestureRecognizer(gesture)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc private func willShowKeyboard(notification: Notification){
        
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let keyboardMinY = keyboardFrame?.minY else {return}
        let registerButtonMaxY = registerButton.frame.maxY
        if registerButtonMaxY > keyboardMinY{
            let distance = registerButtonMaxY - keyboardMinY + 20
            let transform = CGAffineTransform(translationX: 0, y: -distance)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
                self.view.transform = transform
            })
        }
    }
    
    @objc private func willHideKeyboard(){
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = .identity
        })
    }
    
    
    //空欄じゃない事を確かめる基本的バリデーション
    @objc private func registerButtonPressed(){
        
        guard let displayName = displayNameField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty, !password.isEmpty, !displayName.isEmpty else{
                
                ServiceAlert.showSimpleAlert(vc: self, title: "woops..", message: "Please enter all information to register")
                return
        }
        registerUserToFirebaseAuth(email: email, password: password)
    }
    
    
    //FireBaseAuthへの登録作業
    func registerUserToFirebaseAuth(email: String, password: String){
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            
            guard let self = self else {return}
            if let error = error {
                ServiceAlert.showSimpleAlert(vc: self, title: "Failed to register", message: error.localizedDescription)
                return
            }
            
            print("FirebaseAuthへのユーザー登録が成功しました。")
            guard let result = result else {return}
            
            let authUID = result.user.uid
            
            guard let profileImage = self.profileImageView.image else{return}
            
            if profileImage == UIImage(systemName: "person"){ //ユーザーが写真を選んでいない時はそのままFireStoreへgo!
                self.saveUserInfoToFireStore(authUID: authUID, email: email, pictureURL: nil)
                
            }else{    //ユーザーがオリジナル写真を選んでいた時はFireStorageにセーブ
                self.saveUserPictureToFireStorage(authUID: authUID, email: email, profileImage: profileImage)
            }
        }
    }
    
    
    //写真があればFireStorageに保存
    func saveUserPictureToFireStorage(authUID: String, email: String, profileImage: UIImage){
        
        guard let jpegData = profileImage.jpegData(compressionQuality: 0.3) else{return}
        
        FireStorageManager.uploadProfileImage(jpegData: jpegData) { (result) in
            
            switch result{
            case .success(let downloadURL):
                print("ユーザー写真のFireStoregeへの保存に成功しました")
                self.saveUserInfoToFireStore(authUID: authUID, email: email, pictureURL: downloadURL)
            case .failure(_):
                print("ユーザー写真のFireStoregeへの保存に失敗しましたが写真抜きでFireStoreへのセーブ作業に入ります。")
                self.saveUserInfoToFireStore(authUID: authUID, email: email, pictureURL: nil)
            }
        }
    }
    
    //FireAuthに名前の登録、そしてFireStoreにユーザー情報を保存してdismiss
    func saveUserInfoToFireStore(authUID: String, email: String, pictureURL: String?){
        
        let displayName = displayNameField.text!
        
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges(completion: { (error) in
            if error != nil{print("displayNameのFirebaseAuthへの登録に失敗しました\(error!)"); return}
        })
            
        User.saveUserToFireStore(authUID: authUID, email: email, displayName: displayName, pictureURL: pictureURL, firstName: nil, lastName: nil, createdAt: Timestamp()) { (error) in
            
            if error != nil {print("FireStoreへのユーザー情報セーブが失敗しました。"); return}
            
            print("FireStoreへのユーザー登録が成功しました")
            self.dismiss(animated: true, completion: nil)
        }
    }
}


//MARK: - UITextField Delegate Method
extension SignUpVC: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //textField.resignFirstResponder()
        switch textField{
        case displayNameField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            registerButtonPressed()
        default:
            break
        }
        return true
    }
    
}

//MARK: - Image Picker

extension SignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    @objc private func didTapImageView(){
        
        let action1 = UIAlertAction(title: "Take Photo", style: .default) {[weak self] (action) in
            guard let self = self else {return}
            self.presentCamera()
        }
        let action2 = UIAlertAction(title: "Choose Photo", style: .default) {[weak self] (action) in
            guard let self = self else {return}
            self.presentPhotoPicker()
        }
        let action3 = UIAlertAction(title: "Delete Photo", style: .cancel) {[weak self] (action) in
            guard let self = self else {return}
            self.profileImageView.image = UIImage(systemName: "person")
        }
        
        let actions = [action1, action2, action3]
        ServiceAlert.showMultipleSelectionAlert(vc: self, title: "Profile Picture", message: "How would you like to select a picture?", actions: actions)
    }
    
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
        self.profileImageView.image = selectedImage
    }
    
    //    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {  // dismissの必要はないみたい
    //        picker.dismiss(animated: true, completion: nil)
    //    }
    
    
}


