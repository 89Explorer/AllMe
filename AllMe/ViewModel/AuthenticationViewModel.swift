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
    
    
    // FirebaseAuth.User를 AllMeUser로 변환하는 함수
    private func convertToAllMeUser(from user: User) -> AllMeUser {
        return AllMeUser(from: user)
    }
    
    
    func createUser(with credential: AuthCredential) {
        
        // 에러 초기화 목적
        error = nil
        
        AuthenticationManager.shared.signIn(with: credential)
            .handleEvents(receiveOutput: { [weak self] user in
                self?.user = user
            })
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.error = error.localizedDescription
                case .finished:
                    print("회원 가입 성공")
                }
            } receiveValue: { [weak self] user in
                // Firebase User를 AllMeUser로 변환
                self?.createRecord(for: user)
            }
            .store(in: &subscription)
    }
    
    
    /// Firestore에 사용자 정보를 저장
    func createRecord(for user: User) {
        
        guard let displayName = user.displayName,
              let avatarPath = user.photoURL else { return }
        
        let avatarPathString = avatarPath.absoluteString
        
        let allMeUser = AllMeUser(from: user, displayName: displayName, avatarPath: avatarPathString)
        
        DatabaseManager.shared.collectionUsers(add: allMeUser)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.error = error.localizedDescription
                case .finished:
                    print("회원 정보 저장 완료")
                }
            } receiveValue: { state in
                print("회원 정보를 database 저장: \(state)")
            }
            .store(in: &subscription)

    }
}
