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
    
    var authApi: AuthenticationManager!
    var validationService: ValidationService!
    init(authApi: AuthenticationManager, validationService: ValidationService){
        super.init(nibName: nil, bundle: nil)
        self.authApi = authApi
        self.validationService = validationService
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   private let bgImageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(named: "TwoGirls_Fashion")
        iv.contentMode = .scaleAspectFill
        iv.alpha = 0.9
        return iv
    }()
    
    private let clearView: UIView = {  //キーボードが表出した時にboundsを変化させてdarkViewを上下に動かすために使う。
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let darkView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "plus",withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .thin))
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = 60
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        imageView.addGestureRecognizer(gesture)
        return imageView
    }()
    
    private let displayNameField: CustomTextField = {
        let field = CustomTextField()
        field.returnKeyType = .continue
        field.placeholder = "enter display name"
        return field
    }()
    
    private let emailTextField: CustomTextField = {
        let field = CustomTextField()
        field.returnKeyType = .continue
        field.placeholder = "enter email"
        return field
    }()
    
    private let passwordTextField: CustomTextField = {
        let field = CustomTextField()
        field.returnKeyType = .done
        field.placeholder = "enter password"
        field.isSecureTextEntry = true
        return field
    }()
    
    private lazy var registerButton: CustomLoginButton = {
        let button = CustomLoginButton()
        button.setTitle("Register", for: .normal)
        button.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNotifications()
    }
    
    private func setupViews(){
        view.backgroundColor = .white
        displayNameField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        view.addSubview(bgImageView)
        view.addSubview(clearView)
        clearView.addSubview(darkView)
        darkView.addSubview(profileImageView)
        darkView.addSubview(displayNameField)
        darkView.addSubview(emailTextField)
        darkView.addSubview(registerButton)
        darkView.addSubview(passwordTextField)
    }
    
    private func setupNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstrains()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .white
        //以下はnavBarを透明にするためのコード
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupConstrains(){
        let rate = (bgImageView.image?.size.height)! / view.frame.height
        let width = (bgImageView.image?.size.width)! / rate
        let xAdjustment = width * 0.4
        
        bgImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, paddingLeft: (view.frame.width/2)-xAdjustment, width: width)
        
        clearView.fillSuperview()
        
        darkView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 15, paddingBottom: 30, paddingRight: 15, height: 380)
        
        profileImageView.anchor(top: darkView.topAnchor,paddingTop: 20, width: 120, height: 120)
        profileImageView.centerX(inView: view)
        
        displayNameField.anchor(top: profileImageView.bottomAnchor, left: clearView.leftAnchor, right: clearView.rightAnchor, paddingTop: 20, paddingLeft: 50, paddingRight: 50, height: 40)
        
        emailTextField.anchor(top: displayNameField.bottomAnchor, left: displayNameField.leftAnchor, right: displayNameField.rightAnchor, paddingTop: 10, height: 40)
        
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: displayNameField.leftAnchor, right: displayNameField.rightAnchor, paddingTop: 10, height: 40)
        
        registerButton.anchor(top: passwordTextField.bottomAnchor, paddingTop: 15, height: 40)
        registerButton.centerX(inView: clearView)
        registerButton.widthAnchor.constraint(equalTo: displayNameField.widthAnchor, multiplier: 0.5).isActive = true
    }
    
    @objc private func willShowKeyboard(notification: Notification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let keyboardMinY = keyboardFrame?.minY else {return}
        
        let registerButtonMaxY = registerButton.frame.maxY
        if registerButtonMaxY < keyboardMinY{
            let distance = registerButtonMaxY - keyboardMinY + 20
            self.clearView.bounds.origin.y = -distance
        }
    }
    
    @objc private func willHideKeyboard(){
        self.clearView.bounds.origin.y = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    @objc private func registerButtonPressed(){
        
        guard let displayName = displayNameField.text, let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        var infoTuple: (displayName: String, email: String, password: String)
        do{
            infoTuple = try validationService.validate(displayName: displayName, email: email, password: password)
        
        }catch{
            let error = error as! ValidationError
            ServiceAlert.showSimpleAlert(vc: self, title: error.rawValue, message: "")
            return
        }
        
        authApi.registerUserToFirebaseAuth(displayName: infoTuple.displayName, email: infoTuple.email, password: infoTuple.password, profileImage: profileImageView.image!) { [weak self] (error) in
            if let error = error{
                print("Error saving user information: \(error.localizedDescription) ")
                return
            }
            self?.dismiss(animated: true, completion: nil)
        }
    }
}


//MARK: - UITextField Delegate Method
extension SignUpVC: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField{
        case displayNameField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            textField.resignFirstResponder()
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
        let action2 = UIAlertAction(title: "Choose from Photo Library", style: .default) {[weak self] (action) in
            guard let self = self else {return}
            self.presentPhotoPicker()
        }
        let action3 = UIAlertAction(title: "Cancel", style: .cancel) {[weak self] (action) in
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
}


