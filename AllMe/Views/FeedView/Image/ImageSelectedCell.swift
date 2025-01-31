//
//  ImageSelectedCell.swift
//  AllMe
//
//  Created by 권정근 on 1/21/25.
//

import UIKit

class ImageSelectedCell: UITableViewCell {
    
    // MARK: - Variables
    static let reuseIdentifier: String = "ImageSelectedCell"
    
    var selectedImages: [UIImage] = [] {
        didSet {
            self.selectedImageCollectionView.reloadData()
        }
    }
    
    weak var delegate: ImageSelectedDelegate?
    
    // MARK: - UI Components
    private let imageSelectButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.cornerStyle = .medium
        
        // 외곽선 설정
        configuration.background.strokeWidth = 1.0
        configuration.background.strokeColor = .gray
        
        // 이미지 설정
        configuration.image = UIImage(systemName: "camera")
        configuration.imagePadding = 5
        configuration.imagePlacement = .top
        configuration.baseForegroundColor = .systemBlue
        
        // 타이틀 설정
        // configuration.title = "0/10"
        configuration.attributedTitle = AttributedString("0/10", attributes: AttributeContainer([
            .foregroundColor: UIColor.lightGray, // 텍스트 색상 (옅은 회색)
            .font: UIFont.systemFont(ofSize: 14)
        ]))
        
        let button = UIButton(configuration: configuration)
        return button
    }()
    
    private let selectedImageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 80, height: 80)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.layer.cornerRadius = 10
        collectionView.layer.masksToBounds = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    
    // MARK: - Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureConstraints()
        configureCollectionView()
        imageSelectedButtonTapped()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    private func configureCollectionView() {
        selectedImageCollectionView.dataSource = self
        selectedImageCollectionView.delegate = self
        selectedImageCollectionView.register(SelectedImagesCollectionViewCell.self, forCellWithReuseIdentifier: SelectedImagesCollectionViewCell.reuseIdentifier)
    }
    
    func updateImages(_ images: [UIImage]) {
        self.selectedImages = images
    }
    
    private func imageSelectedButtonTapped() {
        imageSelectButton.addTarget(self, action: #selector(addImageButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func addImageButtonTapped() {
        delegate?.didTappedImageSelectedButton(in: self)
    }
    
    @objc private func deleteImage(_ sender: UIButton) {
        let index = sender.tag
        print("deleteImageButton called at index: \(index)")

        // 안전한 인덱스 확인
        guard index >= 0 && index < selectedImages.count else {
            print("삭제할 이미지가 없음")
            return
        }

        let deletedImage = selectedImages.remove(at: index) // ✅ 삭제된 이미지 저장

        // ✅ 삭제된 이미지가 FeedViewController로 전달됨
        delegate?.didDeleteImage(in: self, deletedImage: deletedImage)

        // UI 업데이트
        selectedImageCollectionView.reloadData()
    }

    
//    @objc private func deleteImage(_ sender: UIButton) {
//        print("deleteImageButton called")
//        let index = sender.tag
//        
//        // 안전한 인덱스 범위 확인
//        guard index >= 0 && index < selectedImages.count else {
//            print("삭제할 이미지가 없음")
//            return
//        }
//        // 이미지 삭제
//        selectedImages.remove(at: index)
//        selectedImageCollectionView.reloadData()
//        print("deleteImageButton called at index: \(index)")
//    }
    
    // MARK: - Layouts
    private func configureConstraints() {
        contentView.addSubview(imageSelectButton)
        contentView.addSubview(selectedImageCollectionView)
        
        imageSelectButton.translatesAutoresizingMaskIntoConstraints = false
        selectedImageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            imageSelectButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageSelectButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageSelectButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            imageSelectButton.heightAnchor.constraint(equalToConstant: 80),
            imageSelectButton.widthAnchor.constraint(equalToConstant: 80),
            
            selectedImageCollectionView.leadingAnchor.constraint(equalTo: imageSelectButton.trailingAnchor, constant: 20),
            selectedImageCollectionView.centerYAnchor.constraint(equalTo: imageSelectButton.centerYAnchor),
            selectedImageCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            selectedImageCollectionView.heightAnchor.constraint(equalToConstant: 100)
            
        ])
    }
}

// MARK: - Extension: UICollectionView
extension ImageSelectedCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedImagesCollectionViewCell.reuseIdentifier, for: indexPath) as? SelectedImagesCollectionViewCell else { return UICollectionViewCell() }
        
        // 데이터 가져오기
        let image = indexPath.row < selectedImages.count ? selectedImages[indexPath.row] : nil
        
        
        cell.configure(with: image)
        
        cell.calledDeleteButton().tag = indexPath.row   // 삭제 버튼에 인덱스 전달
        cell.calledDeleteButton().addTarget(self, action: #selector(self.deleteImage(_:)), for: .touchUpInside)
        
        return cell
    }
}


// MARK: - Protocol
// 이미지 선택 버튼의 액션을 전달하기 위한 Delegate 프로토콜 생성
//protocol ImageSelectedDelegate: AnyObject {
//    func didTappedImageSelectedButton(in cell: ImageSelectedCell)
//    func imageAddCell(_ cell: ImageSelectedCell, didSelectImages images: [UIImage])
//}

protocol ImageSelectedDelegate: AnyObject {
    func didTappedImageSelectedButton(in cell: ImageSelectedCell)
    func imageAddCell(_ cell: ImageSelectedCell, didSelectImages images: [UIImage])
    func didDeleteImage(in cell: ImageSelectedCell, deletedImage: UIImage?) // 삭제된 이미지 반영
}
