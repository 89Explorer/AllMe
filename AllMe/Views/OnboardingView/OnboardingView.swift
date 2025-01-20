//
//  OnboardingView.swift
//  AllMe
//
//  Created by 권정근 on 1/19/25.
//


import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class OnboardingView: UIView {
    
    // MARK: - UI Components
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "환영합니다 :)" + "\n" + "오늘은 어땠나요?"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.constraints.first { (constraints) -> Bool in
            return constraints.firstAttribute == .height
        }?.constant = 40.0
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGreen
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layouts
    private func configureConstraints() {
        addSubview(welcomeLabel)
        addSubview(facebookLoginButton)
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        facebookLoginButton.translatesAutoresizingMaskIntoConstraints = false 
        
        NSLayoutConstraint.activate([
            
            welcomeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            welcomeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            welcomeLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
            
            facebookLoginButton.centerXAnchor.constraint(equalTo: welcomeLabel.centerXAnchor),
            facebookLoginButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            facebookLoginButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            facebookLoginButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 250)
            
        ])
    }
    
    // MARK: - Functions
    func calledFaecbookLoginButton() -> FBLoginButton {
        return facebookLoginButton
    }
}

