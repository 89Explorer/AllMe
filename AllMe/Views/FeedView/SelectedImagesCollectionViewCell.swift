//
//  SelectedImagesCollectionViewCell.swift
//  AllMe
//
//  Created by 권정근 on 1/21/25.
//

import UIKit

class SelectedImagesCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Variable
    static let reuseIdentifier: String = "SelectedImagesCollectionViewCell"
    
    // MARK: - UI Components
    private var selectedImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10)), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = .gray
        button.layer.cornerRadius = 10
        button.isUserInteractionEnabled = true
        button.clipsToBounds = true
        return button
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        //contentView.backgroundColor = .systemBackground
        
        configureConstraints()
    }

    // 터치 범위 확장하기 위한 오버라이드
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchArea = calledDeleteButton().frame.insetBy(dx: -10, dy: -10) // 터치 영역 확장
        if touchArea.contains(point) {
            return calledDeleteButton()
        }
        return super.hitTest(point, with: event)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Function
    /// 선택된 이미지를 각 이미지뷰로 전달하는 함수
    func configure(with image: UIImage?) {
        if let image = image {
            selectedImage.image = image
            deleteButton.isHidden = false  // 이미지가 있는 경우 삭제 버튼 표시
        } else {
            selectedImage.image = nil
            deleteButton.isHidden = true   // 이미지가 없는 경우 삭제 버튼 숨김
        }
    }
    
    func calledDeleteButton() -> UIButton {
        return deleteButton
    }
    
    
    // MARK: - Layouts
    private func configureConstraints() {
        contentView.addSubview(selectedImage)
        contentView.addSubview(deleteButton)
        
        selectedImage.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            selectedImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectedImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectedImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectedImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -10),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10),
            deleteButton.widthAnchor.constraint(equalToConstant: 20),
            deleteButton.heightAnchor.constraint(equalToConstant: 20)
            
        ])
    }
    
}
