//
//  AppDelegate.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/18/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//


import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.statusBarStyle = .lightContent
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {print("GoogleSignInの手続き中にエラーが発生しました\(error)"); return}
        
        guard let authentication = user.authentication else {return}
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error { print("Got some error during Auth Log In process via Google.\(error)"); return}
            // User is signed in
            guard let authResult = authResult,
                let email = user.profile.email,   //googleの方の情報(user)からemailをget。authResultからでも同じだとは思う。
                let displayName = user.profile.givenName else{return}  //同じくgoogleのuserからdisplayNameをゲット。
            let userUID = authResult.user.uid //AuthのauthResultからuserIDをゲット。これはgoogleの方のuser.userIDとは異なる。
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didLogInNotificationFromGoogle"), object: nil)  //この時点でLoginVCにログインを知らせて、dismissさせて早々とConversationListVCに遷移させる。
            
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            
            var uploadedPictureURL: String? = nil  //Googleのサーバーにある写真をDLして、それをFireStorageに保存しurlをゲットしたい。
            if user.profile.hasImage{
                if let pictureURL = user.profile.imageURL(withDimension: 200){
                    URLSession.shared.dataTask(with: pictureURL) { (data, response, error) in
                        
                        if error != nil {
                            print("Googleよりprofile Picturの取得に失敗しました。")//returnはせずにnilのまま続ける
                        }else if let data = data{
                            FireStorageManager.uploadProfileImage(jpegData: data) { (result) in
                                switch result{
                                case .success(let url):
                                    uploadedPictureURL = url
                                case .failure(_):
                                    uploadedPictureURL = nil
                                }
                            }
                        }
                    }.resume()
                }
            }
            dispatchGroup.leave()
            dispatchGroup.notify(queue: .global()) {
                User.saveUserToFireStore(authUID: userUID, email: email, displayName: displayName, pictureURL: uploadedPictureURL, firstName: displayName, lastName: nil, createdAt: Timestamp()) { (error) in
                    if error != nil{print("FireStoreへのUser情報の保存に失敗しました"); return}
                }
            }
        }
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
    }
}

