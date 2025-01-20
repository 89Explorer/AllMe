//
//  OnboardingViewController.swift
//  AllMe
//
//  Created by 권정근 on 1/18/25.
//

import UIKit
import FBSDKLoginKit
import Combine
import FirebaseAuth
import GoogleSignIn
import FirebaseCore


class OnboardingViewController: UIViewController {
    
    // MARK: - ViewModel
    private let viewModel = AuthenticationViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    
    // MARK: - UI Components
    private let onboardingView: OnboardingView = {
        let view = OnboardingView()
        return view
    }()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        
        configureConstraints()
        
        onboardingView.calledFaecbookLoginButton().delegate = self
        onboardingView.calledGoogleLoginButton().addTarget(self, action: #selector(didTapGoogleLogin), for: .touchUpInside)
        
        if let token = AccessToken.current,
           !token.isExpired {
            dismiss(animated: true)
        }
        bindView()
    }
    
    
    // MARK: - Layouts
    private func configureConstraints() {
        
        view.addSubview(onboardingView)
        
        onboardingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            onboardingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            onboardingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            onboardingView.topAnchor.constraint(equalTo: view.topAnchor),
            onboardingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
        
    }
    
    // MARK: - Functions
    // ViewModel을 연동하는 함수
    private func bindView() {
        
        viewModel.$user.sink { [weak self] user in
            guard user != nil else { return }
            print("로그인 성공: \(user?.displayName ?? "사용자 이름 없음")")
            self?.dismiss(animated: true)    // 로그인 성공 후 화면 닫기
        }
        .store(in: &cancellables)
        
        viewModel.$error.sink { [weak self] error in
            guard let error = error else { return }
            print("로그인 실패: \(error)")
            self?.showErrorAlert(message: error)
        }
        .store(in: &cancellables)
        
    }
    
    // 에러를 나타내는 경고창함수
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func didTapGoogleLogin() {
        print("didTapGoogleLogin called")
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                print("Google 로그인 실패: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                print("토큰 실패")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            self?.viewModel.createUser(with: credential)
        }
    }
    
}

// MARK: - Extensions

/// facebook 로그인 구현
extension OnboardingViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: (any Error)?) {
        if let error = error {
            print("Facebook 로그인 실패: \(error.localizedDescription)")
            return
        }
        
        // Facebook 로그인 성공 시 Firebase 인증 처리
        guard let accessToken = AccessToken.current else { return }
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
        
        viewModel.createUser(with: credential)
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        print("Facebook 로그아웃 성공")
    }
    
}
