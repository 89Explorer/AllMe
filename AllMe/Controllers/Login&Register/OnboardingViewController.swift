//
//  OnboardingViewController.swift
//  AllMe
//
//  Created by 권정근 on 1/18/25.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    // MARK: - UI Components
    private let onboardingView: OnboardingView = {
        let view = OnboardingView()
        return view
    }()

    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        
        configureConstraints()
    }
    
    
    // MARK: - Layouts
    private func configureConstraints() {
        
        view.addSubview(onboardingView)
        
        onboardingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            onboardingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            onboardingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            onboardingView.topAnchor.constraint(equalTo: view.topAnchor),
            onboardingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
        
    }

}
