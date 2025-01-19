//
//  ViewController.swift
//  AllMe
//
//  Created by 권정근 on 1/18/25.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Variables
    private var hasPresentedOnboarding = false 

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        
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


}

