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
import GoogleSignIn
import RxSwift
import RxCocoa

class LoginVC: UIViewController {
    
    let loginViewModel = LoginViewModel()
    let disposeBag = DisposeBag()
    
    var authApi: AuthenticationManager!
    
    init(authApi: AuthenticationManager) {
        super.init(nibName: nil, bundle: nil)
        self.authApi = authApi
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private let bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ThreePeople")
        imageView.alpha = 0.9
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let darkView: UIView = {
        let dv = UIView()
        dv.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        dv.layer.cornerRadius = 8
        return dv
    }()
    
    private let clearView: UIView = {
        let cv = UIView()
        cv.backgroundColor = .clear
        return cv
    }()
    
    private let fbLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        button.alpha = 0.8
        return button
    }()
    
    private let gmailLoginButton: GIDSignInButton = {
        let button = GIDSignInButton(frame: .zero)
        button.alpha = 0.8
        return button
    }()
    
    private lazy var middleLabel: UIButton = {
        let bn = UIButton(type: .system)
        let string = NSMutableAttributedString(string: "Login, or you can register from ",
                                               attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular),
                                                            .foregroundColor: UIColor.white])
        string.append(NSAttributedString(string: "Here", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .bold),
                                                                      .foregroundColor:UIColor.white]))
        bn.setAttributedTitle(string, for: .normal)
        bn.tintColor = .white  //attributed属性のforegroundColorを白に設定した場合はtintColorで青に上書きされるようなのでここで白にする。
        bn.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return bn
    }()
    
    private let lineUIView: UIView = {
        let line = UIView()
        line.layer.borderWidth = 1
        line.layer.borderColor = UIColor.white.cgColor
        return line
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
    
    private lazy var loginButton: CustomLoginButton = {
        let button = CustomLoginButton()
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupViews()
        setupNotifications()
    }
    
    func setupBindings(){
        emailTextField.rx.text.map{ $0 ?? "" }.bind(to: loginViewModel.emailPublishSubject)
            .disposed(by: disposeBag)
        passwordTextField.rx.text.map{ $0 ?? "" }.bind(to: loginViewModel.passwordPublishSubject)
            .disposed(by: disposeBag)
        
        loginViewModel.isValid().bind(to: loginButton.rx.isEnabled).disposed(by: disposeBag)
        loginViewModel.isValid().map { $0 ? 0.9 : 0.3 }.bind(to: loginButton.rx.alpha).disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    private func setupViews(){
        view.backgroundColor = .white
        emailTextField.delegate = self
        passwordTextField.delegate = self
        fbLoginButton.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        view.addSubview(bgImageView)
        view.addSubview(clearView)
        clearView.addSubview(darkView)
        clearView.addSubview(fbLoginButton)
        clearView.addSubview(gmailLoginButton)
        clearView.addSubview(middleLabel)
        clearView.addSubview(lineUIView)
        clearView.addSubview(emailTextField)
        clearView.addSubview(passwordTextField)
        clearView.addSubview(loginButton)
    }
    
    private func setupNotifications() {
        //このNotificationはAppDelgateからで、Googleのログイン完了の通知が届く。
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "didLogInNotificationFromGoogle"), object: nil, queue: .main) { [weak self](notificaton) in
            guard let self = self else{return}
            self.dismiss(animated: true, completion: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func setConstraints(){
        let rate = (bgImageView.image?.size.height)! / view.frame.height
        let bgImageViewWidth = ((bgImageView.image?.size.width)! / rate)
        let xAdjustment = bgImageViewWidth * 0.42
        
        bgImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, paddingLeft: -xAdjustment)
        bgImageView.widthAnchor.constraint(equalToConstant: bgImageViewWidth).isActive = true
        
        clearView.fillSuperview()
        
        darkView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 15, paddingBottom: 50, paddingRight: 15, height: 350)
        
        fbLoginButton.anchor(top: darkView.topAnchor, left: clearView.leftAnchor, bottom: darkView.topAnchor, right: clearView.rightAnchor, paddingTop: 30, paddingLeft: 50, paddingBottom: -70, paddingRight: 50)
        
        gmailLoginButton.anchor(top: fbLoginButton.bottomAnchor, left: clearView.leftAnchor, right: clearView.rightAnchor, paddingTop: 10, paddingLeft: 46, paddingRight: 46)
        
        
        lineUIView.anchor(top: gmailLoginButton.bottomAnchor, left: fbLoginButton.leftAnchor, right: fbLoginButton.rightAnchor, paddingTop: 10, paddingLeft: -10, paddingRight: -10, height: 1)
        
        middleLabel.anchor(top: lineUIView.topAnchor, right: fbLoginButton.rightAnchor, paddingTop: 10)
        
        emailTextField.anchor(top: middleLabel.bottomAnchor, left: fbLoginButton.leftAnchor, right: fbLoginButton.rightAnchor, paddingTop: 5, height: 40)
        
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: fbLoginButton.leftAnchor, right: fbLoginButton.rightAnchor, paddingTop: 10, height: 40)
        
        loginButton.anchor(top: passwordTextField.bottomAnchor, paddingTop: 15, height: 40)
        loginButton.centerX(inView: clearView)
        loginButton.widthAnchor.constraint(equalTo: fbLoginButton.widthAnchor, multiplier: 0.5).isActive = true
    }
    
    
    @objc private func registerButtonTapped(){
        let signUpVC = SignUpVC(authApi: AuthenticationManager(), validationService: ValidationService())
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
//    @objc private func googleButtonPressed(){  //必要あるのかは不明
//
//        GIDSignIn.sharedInstance().signIn()
//    }
    
    
    
    @objc private func loginButtonPressed(){
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}
        if !email.isValidEmail{
            ServiceAlert.showSimpleAlert(vc: self, title: "Email isn't in correct format.", message:"")
            return
        }
        
        authApi.FirebaseAuthLoginHandling(email: email, password: password) { (error) in
            if let error = error{
                ServiceAlert.showSimpleAlert(vc: self, title: "Failed to log in", message: error.localizedDescription)
                return
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
            
            self.authApi.uploadProfileImage(jpegData: jpegData) { (result) in
                
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
    
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        //clearViewのboundを変更する事により、darkViewを押し上げる
        guard let userInfo = notification.userInfo else { return }
        
        if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
            var shouldMoveViewUp = false
            let bottomLiginButton = loginButton.convert(loginButton.bounds, to: self.clearView).maxY
            let topOfKeyboard = self.clearView.frame.height - keyboardSize.height
            if bottomLiginButton > topOfKeyboard {
                shouldMoveViewUp = true
            }
            if shouldMoveViewUp {
                self.clearView.bounds.origin.y = bottomLiginButton + 10 - topOfKeyboard
            }
        }
    }
    
    @objc func keyboardWillHide() {
        self.clearView.bounds.origin.y = 0
    }

}



//MARK: - UITextFieldDelegate Methods

extension LoginVC: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        switch textField{
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

