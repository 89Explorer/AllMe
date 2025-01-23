//
//  TitleInputCell.swift
//  AllMe
//
//  Created by 권정근 on 1/22/25.
//

import UIKit

class TitleInputCell: UITableViewCell {
    
    // MARK: - Variable
    static let reuseIdentifier: String = "TitleInputCell"
    
    // MARK: - UI Components
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 5
        
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        
        
        textField.text = "글 제목을 입력해주세요 😀"
        textField.textColor = .secondaryLabel
        textField.backgroundColor = .systemBackground
        textField.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return textField
    }()
    
    
    // MARK: - Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Function
    func calledTitleTextField() -> UITextField {
        return titleTextField
    }
    
    
    
    // MARK: - Layouts
    private func configureConstraints() {
        contentView.addSubview(titleTextField)
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleTextField.heightAnchor.constraint(equalToConstant: 50)
            
        ])
    }
}
