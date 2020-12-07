//
//  SceneDelegate.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 11/18/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        //reveloper.comでは、UITabBarControllerを継承したMainTabBarControllerを作り、そのViewDidLoadの中にnavControllerやBarItemなどを書いている。
        //また、FirebaseAuthをインポートしif Auth.auth().currentUser == nil{}などのコードもそのviewDidLoadの中に書いている。
        let tab = MySubclassedTabBarController()
        let conversationListVC = ConversationListVC()
        let friendListVC = FriendListVC()
        let settingVC = SettingVC()
        let nav1 = UINavigationController(rootViewController: conversationListVC)
        let nav2 = UINavigationController(rootViewController: friendListVC)
        let nav3 = UINavigationController(rootViewController: settingVC)
        nav1.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(systemName: "text.bubble"), selectedImage: UIImage(systemName: "text.bubble.fill"))
        nav2.tabBarItem = UITabBarItem(title: "Friends", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        nav3.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "doc.plaintext"), selectedImage: UIImage(systemName: "doc.plaintext.fill"))
        
        tab.viewControllers = [nav1,nav2,nav3]
        UITabBar.appearance().tintColor = .gray
        UINavigationBar.appearance().tintColor = .gray
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 36, weight: .light)]
        UINavigationBar.appearance().largeTitleTextAttributes = attributes
        
        
        window?.rootViewController = tab
        window?.makeKeyAndVisible()
    
    }
    
    
//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        guard let url = URLContexts.first?.url else {
//            return
//        }
//
//        ApplicationDelegate.shared.application(
//            UIApplication.shared,
//            open: url,
//            sourceApplication: nil,
//            annotation: [UIApplication.OpenURLOptionsKey.annotation]
//        )
//    }

    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

