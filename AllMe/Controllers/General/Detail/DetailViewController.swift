//
//  DetailViewController.swift
//  AllMe
//
//  Created by 권정근 on 1/27/25.
//

import UIKit
import Combine

class DetailViewController: UIViewController {
    
    // MARK: - Variable
    var userFeed: FeedItem!
    var userImage: [UIImage]!
    
    private var viewModel: DetailViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: - UI Components
    private let detailView: DetailView = {
        let view = DetailView()
        return view
    }()

    
    // MAKR: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureConstraints()
        
        detailView.viewModel = viewModel
        // Do any additional setup after loading the view.
        
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(didTapUpdate))
        
        navigationItem.rightBarButtonItem = rightButton
        bindView()
        
    }
    
    init(feedItem: FeedItem, image: [UIImage], feedItemViewModel: FeedItemViewModel) {
        self.viewModel = DetailViewModel(feedItem: feedItem, images: image, feedItemViewModel: feedItemViewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func didTapUpdate() {
        print("didTapUpdate - called")
        
        let actionSheet = UIAlertController(title: "설정", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "수정", style: .default, handler: { _ in
            print("수정하기")
            self.updateFeedItem()
        }))
        actionSheet.addAction(UIAlertAction(title: "삭제", style: .default, handler: { _ in
            print("삭제하기")
            self.deleteFeedItem()
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .destructive, handler: nil))
        
        present(actionSheet, animated: true)
        
    }
    
    // MARK: - Function
    func deleteFeedItem() {
        viewModel.deleteFeed()
        navigationController?.popViewController(animated: true)
        
    }
    
//    func updateFeedItem() {
//        let feedItem = viewModel.feedItem
//        let images = viewModel.images
//        
//        let editVC = FeedViewController(mode: .edit(feedItem, images))
//        let navController = UINavigationController(rootViewController: editVC)
//        navController.modalPresentationStyle = .fullScreen
//        present(navController, animated: true)
//        
//    }
    
    func updateFeedItem() {
        let feedItem = viewModel.feedItem
        let images = viewModel.images

        let editVC = FeedViewController(mode: .edit(feedItem, images)) { updatedFeed, updatedImages in
            self.viewModel.updateFeed(title: updatedFeed.title ?? "",
                                      content: updatedFeed.contents ?? "",
                                      images: updatedImages)
        }
        
        let navController = UINavigationController(rootViewController: editVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }

    
    func bindView() {
        viewModel.$feedItem
            .receive(on: RunLoop.main)
            .sink { [weak self] updatedFeed in
                self?.detailView.updateUI(with: updatedFeed)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Layouts
    private func configureConstraints() {
        view.addSubview(detailView)
        
        detailView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            detailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            detailView.topAnchor.constraint(equalTo: view.topAnchor),
            detailView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
    }
}
