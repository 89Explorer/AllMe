//
//  ViewController.swift
//  AllMe
//
//  Created by 권정근 on 1/18/25.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth
import GoogleSignIn
import Combine

class ViewController: UIViewController {
    
    // MARK: - Variables
    private var hasPresentedOnboarding = false
    private var viewModel = FeedItemViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: - UI Components
    private let homeTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private var addItemButton: UIButton = {
        let button = UIButton()
        let plusSign = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .bold))
        button.setImage(plusSign, for: .normal)
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        button.tintColor = .systemYellow
        button.backgroundColor = .systemBackground
        return button
    }()
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        
        configureConstraints()
        configureTableViewDelegate()
        setupBindings()
        
        let logoutButton = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .plain, target: self, action: #selector(didTapLogOut))
        
        addItemButton.addTarget(self, action: #selector(didTapAddItemButton), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = logoutButton
        navigationController?.navigationBar.tintColor = .black
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
        
        viewModel.fetchFeeds()
    }
    
    
    // MARK: - Functions
    private func configureTableViewDelegate() {
        homeTableView.delegate = self
        homeTableView.dataSource = self
        homeTableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.reuseIdentifier)
    }
    
    private func setupBindings() {
        viewModel.$feeds
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.homeTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Actions
    @objc private func didTapLogOut() {
        print("didTapLogOut called")
        FBSDKLoginKit.LoginManager().logOut()
        
        do {
            try FirebaseAuth.Auth.auth().signOut()
            let onBoardingVC = UINavigationController(rootViewController: OnboardingViewController())
            onBoardingVC.modalPresentationStyle = .fullScreen
            present(onBoardingVC, animated: true)
        } catch {
            print("Failed to log out")
        }
        
    }
    
    @objc private func didTapAddItemButton() {
        print("didTapAddItemButton - called")
        let feedVC = UINavigationController(rootViewController: FeedViewController())
        feedVC.modalPresentationStyle = .fullScreen
        self.present(feedVC, animated: true)
        
    }
    
    
    // MARK: - Layouts
    private func configureConstraints() {
        view.addSubview(homeTableView)
        view.addSubview(addItemButton)

        view.bringSubviewToFront(addItemButton)
        
        addItemButton.translatesAutoresizingMaskIntoConstraints = false
        homeTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            homeTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            homeTableView.topAnchor.constraint(equalTo: view.topAnchor),
            homeTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            addItemButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addItemButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            addItemButton.heightAnchor.constraint(equalToConstant: 60),
            addItemButton.widthAnchor.constraint(equalToConstant: 60)
            
        ])
    }
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier, for: indexPath) as? HomeTableViewCell else { return UITableViewCell() }
        
        // 1) 현재 피드 아이템
        let feedItem = viewModel.feeds[indexPath.row]
        
        // 2) 저장된 이미 경로 가져오기
        let paths = feedItem.imagePath
        
        // 3) FileManager에서 이미지 불러오기
        let images = FeedStorageManager.shared.loadImages(from: paths)
        
        // 4) 여러 장 중 첫 번째 이미지를 대표로 사용
        guard let firstImage = images.first ?? UIImage(systemName: "photo") else { return UITableViewCell() }
        
        // 5) 셀 구성
        cell.configureTableView(feedItem: feedItem, image: firstImage)
        
        return cell 
    }
}
