//
//  DetailView.swift
//  AllMe
//
//  Created by 권정근 on 1/29/25.
//

import UIKit
import Combine

class DetailView: UIView {
    
    // MARK: - Variables
    private var cancellables = Set<AnyCancellable>()
    
    var viewModel: DetailViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    // MARK: - UI Components
    private let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 350)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    private let titleLabel: PaddedLabel = {
        let label = PaddedLabel()
        label.textColor = .label
        label.backgroundColor = .secondarySystemBackground
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    
    private let contentLabel: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        textView.backgroundColor = .secondarySystemBackground
        textView.textAlignment = .left
        textView.layer.cornerRadius = 10
        textView.layer.masksToBounds = true
        textView.font = .systemFont(ofSize: 14, weight: .semibold)
        textView.textColor = .label
        return textView
    }()
    
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        configureConstraints()
        configureDelegate()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    private func configureDelegate() {
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    // Combine을 활용한 바인딩
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        // 제목, 내용 업데이트
        viewModel.$feedItem
            .receive(on: RunLoop.main)
            .sink { [weak self] feed in
                self?.titleLabel.text = feed.title
                self?.contentLabel.text = feed.contents
            }
            .store(in: &cancellables)
        
        
        // 이미지 업데이트 (컬렉션 뷰 리로드)
        viewModel.$images
            .receive(on: RunLoop.main)
            .sink { [weak self] _  in
                self?.imageCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    func updateUI(with feedItem: FeedItem) {
        titleLabel.text = feedItem.title
        contentLabel.text = feedItem.contents
    }
    
    // MARK: - Layouts
    private func configureConstraints() {
        addSubview(imageCollectionView)
        addSubview(titleLabel)
        addSubview(contentLabel)
        
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            imageCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            imageCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            imageCollectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            imageCollectionView.heightAnchor.constraint(equalToConstant: 350),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: imageCollectionView.bottomAnchor, constant: 15),
            titleLabel.heightAnchor.constraint(equalToConstant: 60),
            
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            contentLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -5)
            
        ])
    }
}

extension DetailView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        if let image = viewModel?.images[indexPath.row] {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            cell.contentView.addSubview(imageView)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                
                imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 0),
                imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 0),
                imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 0),
                imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
                
            ])
            
        }
        
        return cell
        
    }
}
