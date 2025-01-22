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
import GoogleSignIn

class ViewController: UIViewController {
    
    // MARK: - Variables
    private var hasPresentedOnboarding = false
    
    // MARK: - UI Components
    private var addItemButton: UIButton = {
        let button = UIButton()
        let plusSign = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .bold))
        button.setImage(plusSign, for: .normal)
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        button.tintColor = .systemYellow
        button.backgroundColor = .systemBackground
        return button
    }()

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        
        configureConstraints()
        
        let logoutButton = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .plain, target: self, action: #selector(didTapLogOut))
        
        addItemButton.addTarget(self, action: #selector(didTapAddItemButton), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = logoutButton
        navigationController?.navigationBar.tintColor = .black
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
    
    // MARK: - Layouts
    private func configureConstraints() {
        view.addSubview(addItemButton)
        
        addItemButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            addItemButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addItemButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            addItemButton.heightAnchor.constraint(equalToConstant: 60),
            addItemButton.widthAnchor.constraint(equalToConstant: 60)
            
        ])
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
    
    
    @objc private func didTapAddItemButton() {
        print("didTapAddItemButton - called")
        let feedVC = UINavigationController(rootViewController: FeedViewController())
        feedVC.modalPresentationStyle = .fullScreen
        self.present(feedVC, animated: true)
        
    }
}

