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
import RxSwift
import RxCocoa

class SettingVC: UIViewController {
    
    private var myUser: User!
    
    private var viewModel: SettingViewModel!
    private let disposeBag = DisposeBag()
    init(viewModel: SettingViewModel, myUserObject: User) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.myUser = myUserObject
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var pictureURL = ""{
        didSet{
            guard let url = URL(string: pictureURL) else{return}
            profileImageView.sd_setImage(with: url, placeholderImage: nil, completed: nil)
        }
    }
    
    private var newProfilePictureSelected: Bool = false
    private var newProfilePicture: UIImage?
    
    
    private var textCount: Int = 0

    private var actualEditDone: Bool = false
    
    private let bgImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gradation")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "plus")
        iv.layer.cornerRadius = 60
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 1
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.tintColor = .white
        iv.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profilePictureTapped))
        iv.addGestureRecognizer(tapGesture)
        return iv
    }()
    private let displayNameLabel: AccountUILabel = {
        let label = AccountUILabel()
        label.text = "Display Name :"
        return label
    }()
    private let displayNameField: AccountTextField = {
        let field = AccountTextField()
        return field
    }()
    private let emailLabel: AccountUILabel = {
        let label = AccountUILabel()
        label.text = "Email :"
        return label
    }()
    private let emailField: AccountTextField = {
        let field = AccountTextField()
        return field
    }()
    private let statusLabel: AccountUILabel = {
        let label = AccountUILabel()
        label.text = "Your Current Mood :"
        return label
    }()
    private let numberOfCharactorsLabel: AccountUILabel = {
        let label = AccountUILabel()
//        label.text = "(25/25)"
        return label
    }()
    private let statusField: AccountTextField = {
        let field = AccountTextField()
        return field
    }()
    private lazy var editCancelButton: AccountButton = {
        let button = AccountButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var saveButton: AccountButton = {
        let button = AccountButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private let line1 = AccountLine()
    private let line2 = AccountLine()
    private let line3 = AccountLine()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        guard let safeUID = Auth.auth().currentUser?.uid else{return}
//        self.myUID = safeUID
        setupBindings()
        setupViews()
        setupNotification()
    }
    
    override func viewDidLayoutSubviews() {
        setupConstraints()
    }
    
    private func setupBindings(){
        
        displayNameField.rx.text.map{ $0 ?? "" }.bind(to: self.viewModel.displayName).disposed(by: disposeBag)
        emailField.rx.text.map{ $0 ?? "" }.bind(to: self.viewModel.email).disposed(by: disposeBag)
        statusField.rx.text.map{ $0 ?? "" }.bind(to: self.viewModel.status).disposed(by: disposeBag)
        
        setDefaultValues()
        
        viewModel.canSave.bind(to: saveButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.canSave.map{ $0 ? 1 : 0.5 }.bind(to: saveButton.rx.alpha).disposed(by: disposeBag)
        viewModel.canSave.map{ $0 ? #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1) : UIColor.gray}.bind(to: saveButton.rx.backgroundColor).disposed(by: disposeBag)
        
        viewModel.canSave.bind(to: editCancelButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.canSave.map{ $0 ? 1 : 0.5 }.bind(to: editCancelButton.rx.alpha).disposed(by: disposeBag)
        viewModel.canSave.map{ $0 ? #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1) : UIColor.gray}.bind(to: editCancelButton.rx.backgroundColor).disposed(by: disposeBag)
        
        viewModel.status.map{$0.count}.map{"\($0)/25"}.bind(to: numberOfCharactorsLabel.rx.text).disposed(by: disposeBag)
    }
    
    private func setDefaultValues(){
        displayNameField.text = myUser.displayName
        emailField.text = myUser.email
        statusField.text = myUser.status
        pictureURL = myUser.pictureURL ?? ""
    }
    
    
    private func setupViews(){
        displayNameField.delegate = self
        emailField.delegate = self
        statusField.delegate = self
        
        title = "Account Setting"
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.prefersLargeTitles = true
        let barButtonItem = UIBarButtonItem(title: "Log Out", style: .done, target: self, action: #selector(logOutButtonPressed))
        barButtonItem.tintColor = .white
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
            let bottomOfTextField = statusField.convert(statusField.bounds, to: self.view).maxY
            let topOfKeyboard = self.view.frame.height - keyboardSize.height
            
            if bottomOfTextField > topOfKeyboard {
                self.view.frame.origin.y = topOfKeyboard - bottomOfTextField - 70
            }
        }
    }
    
    @objc func keyboardWillHide() {
        self.view.frame.origin.y = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func setupConstraints(){
        view.addSubview(bgImageView)
        view.addSubview(profileImageView)
        view.addSubview(displayNameLabel)
        view.addSubview(displayNameField)
        view.addSubview(emailLabel)
        view.addSubview(emailField)
        view.addSubview(statusLabel)
        view.addSubview(numberOfCharactorsLabel)
        view.addSubview(statusField)
        view.addSubview(editCancelButton)
        view.addSubview(saveButton)
        view.addSubview(line1)
        view.addSubview(line2)
        view.addSubview(line3)
        
        bgImageView.fillSuperview()
        
        profileImageView.anchor(top: view.topAnchor, paddingTop: 180, width: 120, height: 120)
        profileImageView.centerX(inView: view)
        
        displayNameLabel.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingRight: 30)
        
        displayNameField.anchor(top: displayNameLabel.bottomAnchor, left: displayNameLabel.leftAnchor, right: displayNameLabel.rightAnchor, paddingTop: 7)
        
        line1.anchor(top: displayNameField.bottomAnchor, left: displayNameLabel.leftAnchor, right: displayNameLabel.rightAnchor, height: 1)
        
        
        emailLabel.anchor(top: line1.bottomAnchor, left: displayNameLabel.leftAnchor, right: displayNameLabel.rightAnchor, paddingTop: 20)
        
        emailField.anchor(top: emailLabel.bottomAnchor, left: displayNameLabel.leftAnchor, right: displayNameLabel.rightAnchor, paddingTop: 7)
        
        line2.anchor(top: emailField.bottomAnchor, left: displayNameLabel.leftAnchor, right: displayNameLabel.rightAnchor, height: 1)
        
        
        statusLabel.anchor(top: line2.bottomAnchor, left: displayNameLabel.leftAnchor, right: displayNameLabel.rightAnchor, paddingTop: 20)
        
        statusField.anchor(top: statusLabel.bottomAnchor, left: displayNameLabel.leftAnchor, right: displayNameLabel.rightAnchor, paddingTop: 7)
        
        line3.anchor(top: statusField.bottomAnchor, left: displayNameLabel.leftAnchor, right: displayNameLabel.rightAnchor, height: 1)
        
        numberOfCharactorsLabel.firstBaselineAnchor.constraint(equalTo: statusLabel.firstBaselineAnchor).isActive = true
        numberOfCharactorsLabel.anchor(right: displayNameLabel.rightAnchor)
        
        editCancelButton.anchor(top: statusField.bottomAnchor, right: view.centerXAnchor, paddingTop: 30, paddingRight: 10,  height: 32)
        editCancelButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.20).isActive = true
        
        saveButton.anchor(top: editCancelButton.topAnchor, left: view.centerXAnchor, paddingLeft: 10)
        saveButton.widthAnchor.constraint(equalTo: editCancelButton.widthAnchor).isActive = true
        saveButton.heightAnchor.constraint(equalTo: editCancelButton.heightAnchor).isActive = true
    }
    
    
    
    @objc private func profilePictureTapped(){
        
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
        guard let displayName = displayNameField.text, let email = emailField.text, let status = statusField.text else{return}

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

//        判断は迷ったが、ここでローカルのemail, displayName, statusをグローバルの変数に代入する事にした。
        myUser.email = email
        myUser.displayName = displayName
        myUser.status = status
        
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
            "displayName": myUser.displayName,
            "email": myUser.email,
            "pictureURL": downloadURL ?? "" as Any,
            "status": myUser.status ?? ""] as [String : Any]
        
        
        Firestore.firestore().collection("users").document(myUser.authUID).updateData(dictionary) { (error) in
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
        setDefaultValues()
        actualEditDone = false
        newProfilePictureSelected = false
//        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 34, weight: .light, scale: .default)
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
