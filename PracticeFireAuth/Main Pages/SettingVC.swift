//
//  SettingVC.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/18/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

import UIKit
import Firebase
import SDWebImage


class SettingVC: UIViewController {
    
    private var quoteListener: ListenerRegistration?
    
    private var myUID = ""
    
    private var pictureURL = ""{
        didSet{
            guard let url = URL(string: pictureURL) else{return}
            profileImageView.sd_setImage(with: url, placeholderImage: nil, completed: nil)
        }
    }
    
    private var displayName = ""{
        didSet{
            displayNameField.text = displayName
        }
    }
    private var email = ""{
        didSet{
            emailField.text = email
        }
    }
    private var status = ""{
        didSet{
            statusField.text = status
        }
    }
    
    private var activeTextField : UITextField?
    private var textCount: Int = 0{
        didSet{
            numberOfCharactorsLabel.text = "\(25 - textCount)/25"
        }
    }
    private var newProfilePictureSelected: Bool = false
    private var newProfilePicture: UIImage?
    private var actualEditDone: Bool = false
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person")
        imageView.layer.cornerRadius = 60
        imageView.layer.borderColor = UIColor.darkGray.cgColor
        imageView.layer.borderWidth = 1.5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private lazy var lockButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 34, weight: .light, scale: .default)
        button.setImage(UIImage(systemName: "lock", withConfiguration: symbolConfig), for: .normal)
        button.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        button.addTarget(self, action: #selector(lockButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let changePictureButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.setTitle("Change Pic", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1).withAlphaComponent(0.6)
        button.addTarget(self, action: #selector(changePictureButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let displayNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Display Name:"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let displayNameField: MyTextField = {
        let field = MyTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isUserInteractionEnabled = false
        field.layer.cornerRadius = 11
        field.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        field.text = "DisplayName here"
        field.textColor = .gray
        return field
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "email:"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    private let emailField: MyTextField = {
        let field = MyTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isUserInteractionEnabled = false
        field.layer.cornerRadius = 11
        field.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        field.text = "abcdef@gmail.com"
        field.textColor = .gray
        return field
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Your status:"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let numberOfCharactorsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "(25/25)"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    
    private let statusField: MyTextField = {
        let field = MyTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isUserInteractionEnabled = false
        field.text = "Im"
        field.layer.cornerRadius = 11
        field.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        field.placeholder = "less than 25 charactors"
        field.textColor = .gray
        return field
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private var line1: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.layer.borderColor = UIColor.darkGray.cgColor
        line.layer.borderWidth = 1
        return line
    }()
    private var line2: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.layer.borderColor = UIColor.darkGray.cgColor
        line.layer.borderWidth = 1
        return line
    }()
    private var line3: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.layer.borderColor = UIColor.darkGray.cgColor
        line.layer.borderWidth = 1
        return line
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let safeUID = Auth.auth().currentUser?.uid else{return}
        self.myUID = safeUID
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white
        title = "Account"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOutButtonPressed))
        
        displayNameField.delegate = self
        emailField.delegate = self
        statusField.delegate = self
        
        fetchDataFromFirebase()
        setupViews()
        setupNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if let quoteListener = self.quoteListener{
            quoteListener.remove()
            print("リスナ-removed")
        }
    }
    
    private func fetchDataFromFirebase(){
        
        quoteListener = Firestore.firestore().collection("users").document(myUID).addSnapshotListener {[weak self] (snapshot, error) in
            
            guard let self = self else{return}
            if error != nil {print(error!); return}
            guard let snapshot = snapshot, let dictionary = snapshot.data() else{return}
            let status = dictionary["status"] as? String ?? ""
            let pictureURL = dictionary["pictureURL"] as? String ?? ""
            let email = dictionary["email"] as? String ?? ""
            let displayName = dictionary["displayName"] as? String ?? ""
            
            self.status = status
            self.pictureURL = pictureURL
            self.email = email
            self.displayName = displayName
        }
    }
    
    private func setupNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
            var shouldMoveViewUp = false
            
            //if let activeTextField = activeTextField{
            
            let bottomOfTextField = statusField.convert(statusField.bounds, to: self.view).maxY
            print(bottomOfTextField)
            let topOfKeyboard = self.view.frame.height - keyboardSize.height
            print(topOfKeyboard)
            
            if bottomOfTextField > topOfKeyboard {
                shouldMoveViewUp = true
            }
            
            if shouldMoveViewUp {
                self.view.frame.origin.y = topOfKeyboard - bottomOfTextField - 70
            }
            //}
        }
    }
    
    @objc func keyboardWillHide() {
        self.view.frame.origin.y = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func setupViews(){
        
        view.addSubview(profileImageView)
        view.addSubview(lockButton)
        view.addSubview(changePictureButton)
        view.addSubview(displayNameLabel)
        view.addSubview(displayNameField)
        view.addSubview(emailLabel)
        view.addSubview(emailField)
        view.addSubview(statusLabel)
        view.addSubview(numberOfCharactorsLabel)
        view.addSubview(statusField)
        view.addSubview(cancelButton)
        view.addSubview(saveButton)
        view.addSubview(line1)
        view.addSubview(line2)
        view.addSubview(line3)
        
        profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        lockButton.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: -20).isActive = true
        lockButton.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 20).isActive = true
        lockButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        lockButton.widthAnchor.constraint(equalTo: lockButton.heightAnchor).isActive = true
        
        changePictureButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
        changePictureButton.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor).isActive = true
        changePictureButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        changePictureButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        displayNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20).isActive = true
        displayNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        displayNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        
        displayNameField.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 7).isActive = true
        displayNameField.leadingAnchor.constraint(equalTo: displayNameLabel.leadingAnchor).isActive = true
        displayNameField.trailingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor).isActive = true
        
        line1.topAnchor.constraint(equalTo: displayNameField.bottomAnchor, constant: 1).isActive = true
        line1.leadingAnchor.constraint(equalTo: displayNameLabel.leadingAnchor).isActive = true
        line1.trailingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor).isActive = true
        line1.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        emailLabel.topAnchor.constraint(equalTo: displayNameField.bottomAnchor, constant: 20).isActive = true
        emailLabel.leadingAnchor.constraint(equalTo: displayNameLabel.leadingAnchor).isActive = true
        emailLabel.trailingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor).isActive = true
        
        emailField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 7).isActive = true
        emailField.leadingAnchor.constraint(equalTo: displayNameLabel.leadingAnchor).isActive = true
        emailField.trailingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor).isActive = true
        
        line2.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 1).isActive = true
        line2.leadingAnchor.constraint(equalTo: displayNameLabel.leadingAnchor).isActive = true
        line2.trailingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor).isActive = true
        line2.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        statusLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20).isActive = true
        statusLabel.leadingAnchor.constraint(equalTo: displayNameLabel.leadingAnchor).isActive = true
        statusLabel.trailingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor).isActive = true
        
        numberOfCharactorsLabel.firstBaselineAnchor.constraint(equalTo: statusLabel.firstBaselineAnchor).isActive = true
        numberOfCharactorsLabel.trailingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor).isActive = true
        
        statusField.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 7).isActive = true
        statusField.leadingAnchor.constraint(equalTo: displayNameLabel.leadingAnchor).isActive = true
        statusField.trailingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor).isActive = true
        
        line3.topAnchor.constraint(equalTo: statusField.bottomAnchor, constant: 1).isActive = true
        line3.leadingAnchor.constraint(equalTo: displayNameLabel.leadingAnchor).isActive = true
        line3.trailingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor).isActive = true
        line3.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        cancelButton.topAnchor.constraint(equalTo: statusField.bottomAnchor, constant: 30).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10).isActive = true
        cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.20).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        saveButton.topAnchor.constraint(equalTo: cancelButton.topAnchor).isActive = true
        saveButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10).isActive = true
        saveButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor).isActive = true
        saveButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor).isActive = true
    }
    
    
    @objc private func lockButtonPressed(){
        
        lockButton.isEnabled = false
        lockButton.tintColor = .lightGray
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 34, weight: .light, scale: .default)
        lockButton.setImage(UIImage(systemName: "lock.open", withConfiguration: symbolConfig), for: .normal)
        
        changePictureButton.isHidden = false
        
        displayNameField.isUserInteractionEnabled = true
        emailField.isUserInteractionEnabled = true
        statusField.isUserInteractionEnabled = true
        
        displayNameField.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        emailField.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        statusField.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        statusField.placeholder = ""
        
        cancelButton.isEnabled = true
        cancelButton.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
    }
    
    @objc private func changePictureButtonPressed(){
        
        let action1 = UIAlertAction(title: "Take Photo", style: .default) { [weak self](action) in
            
            guard let self = self else{return}
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }
        let action2 = UIAlertAction(title: "Photo Library", style: .default) { [weak self](action) in
            
            guard let self = self else{return}
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
        let action3 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ServiceAlert.showMultipleSelectionAlert(vc: self, title: "How would you like to pick your profile picture?", message: "", actions: [action1, action2, action3])
        
    }
    
    
    
    
    
    @objc private func saveButtonPressed(){
        
        //バリデーション。そして、各情報をグローバルの変数に代入して更新する。
        guard let displayName = displayNameField.text, let email = emailField.text,
            let status = statusField.text else{return}
        
        if !email.isValidEmail{
            ServiceAlert.showSimpleAlert(vc: self, title: "Email is in invalid format.", message: "Please check out once again")
            return
        }
        if displayName.isEmpty{
            ServiceAlert.showSimpleAlert(vc: self, title: "Please enter Display Name.", message: "")
            return
        }
        
        //Authにemail更新
        guard let currentUser = Auth.auth().currentUser else{return}
        currentUser.updateEmail(to: email) { (error) in
            if error != nil{print("Authへのemailのアップデート登録に失敗しました\(error!)"); return}
        }
        
        //AuthにDisplayName更新
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges(completion: { (error) in
            if error != nil{print("AuthへのDisplay Nameのアップデート登録に失敗しました\(error!)"); return}
        })
        
        //判断は迷ったが、ここでローカルのemail, displayName, statusをグローバルの変数に代入する事にした。
        self.email = email
        self.displayName = displayName
        self.status = status
        
        //FireStorageにprofilePicture更新してURLゲット
        if newProfilePictureSelected{
            
            guard let newProfilePicture = newProfilePicture else{return}
            guard let jpegData = newProfilePicture.jpegData(compressionQuality: 0.3) else{return}
            FireStorageManager.uploadProfileImage(jpegData: jpegData) {[weak self] (result) in
                
                guard let self = self else{return}
                switch result{
                case .success(let downloadURL):
                    self.saveToFireStore(downloadURL: downloadURL)
                case .failure(let error):
                    print(print("ForeStorageへのprofile picの保存に失敗しました。\(error)"))
                }
            }
        }else{
            saveToFireStore(downloadURL: nil)
        }
    }
    
    //FireStoreに保存
    func saveToFireStore(downloadURL: String?){
        
        let dictionary = [
            "displayName": displayName,
            "email": email,
            "pictureURL": pictureURL as Any,
            "status": status] as [String : Any]
        
        print(dictionary)
        Firestore.firestore().collection("users").document(myUID).updateData(dictionary) { (error) in
            if error != nil{
                print("新しいユーザー情報のFireStoreへの更新に失敗しました\(error!)")
            }
        }
        //画面を初期化して、元のlockされた状態に戻す。
        ServiceAlert.showSimpleAlert(vc: self, title: "Successfully saved your account info", message: "")
        resetAllProperties()
    }
    
    
    @objc private func cancelButtonPressed(){
        
        resetAllProperties()
    }
    
    private func resetAllProperties(){
        
        actualEditDone = false
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 34, weight: .light, scale: .default)
        lockButton.setImage(UIImage(systemName: "lock", withConfiguration: symbolConfig), for: .normal)
        lockButton.isEnabled = true
        lockButton.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        
        newProfilePictureSelected = false
        
        displayNameField.isUserInteractionEnabled = false
        displayNameField.text = displayName
        displayNameField.textColor = .lightGray
        emailField.isUserInteractionEnabled = false
        emailField.text = email
        emailField.textColor = .lightGray
        statusField.isUserInteractionEnabled = false
        statusField.text = status
        statusField.textColor = .lightGray
        statusField.placeholder = "less than 25 charactors"
        guard let url = URL(string: pictureURL) else{return}
        profileImageView.sd_setImage(with: url, placeholderImage: nil, completed: nil)
        
        cancelButton.isEnabled = false
        saveButton.isEnabled = false
        cancelButton.backgroundColor = .lightGray
        saveButton.backgroundColor = .lightGray
        
        changePictureButton.isHidden = true
        
    }
    
    @objc private func logOutButtonPressed(){
        
        let action1 = UIAlertAction(title: "OK", style: .default) { (action) in
            do{
                try Auth.auth().signOut()
            }catch{
                print("failed to log out from Firebase Auth sign in")
            }
            
            FBSDKLoginKit.LoginManager().logOut()
            
        }
        
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ServiceAlert.showMultipleSelectionAlert(vc: self, title: "Logging out", message: "Would you really like to log out?", actions: [action1, action2])
    }
    
}


extension SettingVC:  UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        actualEditDone = true
        saveButton.isEnabled = true
        saveButton.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        
        
        if textField == statusField{
            
            let currentText = textField.text ?? ""
            textCount = currentText.count
            print(textCount)
            // attempt to read the range they are trying to change, or exit if we can't
            guard let stringRange = Range(range, in: currentText) else { return false }
            
            // add their new text to the existing text
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            // make sure the result is under 16 characters
            return updatedText.count <= 25
        }
        
        return true
    }
    
}

extension SettingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedPicture = info[.editedImage] as? UIImage{
            
            newProfilePicture = selectedPicture
            
            actualEditDone = true
            newProfilePictureSelected = true
            
            profileImageView.image = selectedPicture
            saveButton.isEnabled = true
            saveButton.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            dismiss(animated: true, completion: nil)
            
        }
    }
}

class MyTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 5, left: 9, bottom: 0, right: 9)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
