//
//  FeedViewController.swift
//  AllMe
//
//  Created by 권정근 on 1/21/25.
//

import UIKit
import PhotosUI

class FeedViewController: UIViewController {
    
    // MARK: - Variable
    private let tableSection: [String] = ["이미지", "제목", "내용"]
    var selectedImages: [UIImage] = []
    
    // MARK: - UI Components
    private let feedTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemMint
        configureConstraints()
        setupTableViewDelegate()
        
        navigationItem.title = "오늘 리뷰 쓰기"

        let backButton = UIBarButtonItem(image: UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16)), style: .done, target: self, action: #selector(didTapBack))
        
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = .black

    }
    
    // MARK: - Functions
    // 테이블 뷰 대리자 선언 함수
    private func setupTableViewDelegate() {
        
        feedTableView.delegate = self
        feedTableView.dataSource = self
        feedTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        feedTableView.register(ImageSelectedCell.self, forCellReuseIdentifier: ImageSelectedCell.reuseIdentifier)
    }
    
    
    // MARK: - Actions
    @objc private func didTapBack() {
        dismiss(animated: true)
    }
    
    // MARK: - Layout
    private func configureConstraints() {
        view.addSubview(feedTableView)
        
        feedTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            feedTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            feedTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            feedTableView.topAnchor.constraint(equalTo: view.topAnchor),
            feedTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
    }
}

// MARK: - Extension: TableView
extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        
        switch section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageSelectedCell.reuseIdentifier, for: indexPath) as? ImageSelectedCell else { return UITableViewCell() }
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSection[section]
    }
    
}

// MARK: - Extension: ImageSelectedDelegate
extension FeedViewController: ImageSelectedDelegate {
    func didTappedImageSelectedButton(in cell: ImageSelectedCell) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 10
        configuration.selection = .ordered
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imageAddCell(_ cell: ImageSelectedCell, didSelectImages images: [UIImage]) {
        cell.updateImages(images)
    }
}


// MARK: - Extension: PHPickerViewControllerDelegate
extension FeedViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let group = DispatchGroup()
        selectedImages.removeAll()
        for item in results {
            group.enter()
            item.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    self.selectedImages.append(image)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let cell = self.feedTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ImageSelectedCell {
                self.imageAddCell(cell, didSelectImages: self.selectedImages)
                
            }
        }
    }
}
