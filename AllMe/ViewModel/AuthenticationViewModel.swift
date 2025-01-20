//
//  AuthenticationViewModel.swift
//  AllMe
//
//  Created by 권정근 on 1/20/25.
//

import Foundation
import FirebaseAuth
import Combine

final class AuthenticationViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var error: String?
    
    private var subscription: Set<AnyCancellable> = []
    
    
    func createUser(with credential: AuthCredential) {
        
        // 에러 초기화 목적
        error = nil
        
        AuthenticationManager.shared.signIn(with: credential)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.error = error.localizedDescription
                case .finished:
                    print("회원 가입 성공")
                } 
            } receiveValue: { [weak self] user in
                self?.user = user
            }
            .store(in: &subscription)
    }
    
}
