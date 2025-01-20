//
//  ViewController.swift
//  AllMe
//
//  Created by 권정근 on 1/18/25.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth

class ViewController: UIViewController {
    
    // MARK: - Variables
    private var hasPresentedOnboarding = false 

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        
        let logoutButton = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .plain, target: self, action: #selector(didTapLogOut))
        
        navigationItem.rightBarButtonItem = logoutButton
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hasPresentedOnboarding {
            hasPresentedOnboarding = true
            
            let loginUser: Bool = false
            
            if !loginUser {
                let onBoardingVC = UINavigationController(rootViewController: OnboardingViewController())
                onBoardingVC.modalPresentationStyle = .fullScreen
                self.present(onBoardingVC, animated: true)
            }
        }
    }

    // MARK: - Actions
    @objc private func didTapLogOut() {
        print("didTapLogOut called")
        FBSDKLoginKit.LoginManager().logOut()
        
        do {
            try FirebaseAuth.Auth.auth().signOut()
            let onBoardingVC = UINavigationController(rootViewController: OnboardingViewController())
            onBoardingVC.modalPresentationStyle = .fullScreen
            present(onBoardingVC, animated: true)
        } catch {
            print("Failed to log out")
        }
        
    }

}

