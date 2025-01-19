//
//  OnboardingView.swift
//  AllMe
//
//  Created by 권정근 on 1/19/25.
//

import UIKit

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
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            welcomeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            welcomeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            welcomeLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30)
            
        ])
    }
}
