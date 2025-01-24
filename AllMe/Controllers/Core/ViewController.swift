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
        homeTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let feed = viewModel.feeds[indexPath.row]
        
        cell.textLabel?.text = feed.title
        
        return cell
    }
}
