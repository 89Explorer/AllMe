//
//  SceneDelegate.swift
//  AllMe
//
//  Created by 권정근 on 1/18/25.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // Facebook 로그인
    // 이 코드는 앱이 시작될 때 SDK를 초기화하며, 로그인이나 공유 작업을 수행할 때
    // SDK가 Facebook 네이티브 앱의 로그인과 공유를 처리하도록 합니다.
    // 그렇지 않으면 사용자가 Facebook에 로그인한 상태에서만 앱 내 브라우저를 통해 로그인할 수 있습니다.
    func scene(_ scene: UIScene,
               openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        
        //        ApplicationDelegate.shared.application(
        //            UIApplication.shared,
        //            open: url,
        //            sourceApplication: nil,
        //            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        //        )
        
        // Facebook 및 Google URL 처리
        let handledByFacebook = ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            options: [:]
        )
        let handledByGoogle = GIDSignIn.sharedInstance.handle(url)
        
        if !handledByFacebook && !handledByGoogle {
            print("URL 처리 실패: \(url)")
        }
    }
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        self.setupWindow(with: scene)
        let vc = ViewController()
        let nav = UINavigationController(rootViewController: vc)
        self.window?.rootViewController = nav
        
    }
    
    
    private func setupWindow(with scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        self.window?.makeKeyAndVisible()
    }
    
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
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
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}

