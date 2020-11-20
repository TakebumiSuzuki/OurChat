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
    
    lazy var firstNameField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 8
        field.layer.borderWidth = 1.5
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "enter your first name"
        field.backgroundColor = .secondarySystemBackground
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    lazy var lastNameField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 8
        field.layer.borderWidth = 1.5
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "enter your last name"
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
        button.addTarget(self, action: #selector(registerUserToFirebase), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "sign up"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(registerUserToFirebase))
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        setUpViews()
        layoutViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    private func setUpViews(){
        view.addSubview(profileImageView)
        view.addSubview(firstNameField)
        view.addSubview(lastNameField)
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
        
        firstNameField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 30).isActive = true
        firstNameField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        firstNameField.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 20).isActive = true
        firstNameField.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -20).isActive = true
        
        lastNameField.topAnchor.constraint(equalTo: firstNameField.bottomAnchor, constant: 20).isActive = true
        lastNameField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        lastNameField.leadingAnchor.constraint(equalTo: firstNameField.leadingAnchor).isActive = true
        lastNameField.trailingAnchor.constraint(equalTo: firstNameField.trailingAnchor).isActive = true
        
        emailTextField.topAnchor.constraint(equalTo: lastNameField.bottomAnchor, constant: 20).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: firstNameField.leadingAnchor).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: firstNameField.trailingAnchor).isActive = true
        
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: firstNameField.leadingAnchor).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: firstNameField.trailingAnchor).isActive = true
        
        registerButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30).isActive = true
        registerButton.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        registerButton.widthAnchor.constraint(equalTo: firstNameField.widthAnchor, multiplier: 0.6).isActive = true
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
    
    @objc private func registerUserToFirebase(){
        
        guard let firstName = firstNameField.text,
            let lastName = lastNameField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty, !password.isEmpty, !lastName.isEmpty, !firstName.isEmpty else{
                ServiceAlert.showSimpleAlert(vc: self, title: "woops..", message: "Please enter all information to register")
                return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            
            guard let self = self else {return}
            
            if let error = error {
                ServiceAlert.showSimpleAlert(vc: self, title: "Failed to register", message: error.localizedDescription)
                return
            }
            guard let result = result else {return} ; print("Successfully registered to Firebase Auth")
            let userID = result.user.uid
            self.saveUserToFireStore(firstName: firstName, lastName: lastName, email: email, userID: userID)
        }
    }
    
    
    private func saveUserToFireStore(firstName: String, lastName: String, email: String, userID: String){
        
        let docData = ["email": email, "firstName": firstName, "lastName": lastName, "createdAt": Timestamp()] as [String: Any]
        
        Firestore.firestore().collection("users").document(userID).setData(docData){ [weak self] (error) in
            
            guard let self = self else {return}
            if let error = error{
                print("Failed to save user info Firestore. \(error.localizedDescription)" ) ; return
            }
            //databaseに写真も保存
            print("successfully saved in Firestore")
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
            print(data)
            let user = User.init(dic: data, userID: userID, pictureURL: pictureURL)
            
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
}








//MARK: - UITextField Delegate Method
extension SignUpVC: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //textField.resignFirstResponder()
        switch textField{
        case firstNameField:
            lastNameField.becomeFirstResponder()
        case lastNameField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            registerUserToFirebase()
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
        let action2 = UIAlertAction(title: "Chose Photo", style: .default) {[weak self] (action) in
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


