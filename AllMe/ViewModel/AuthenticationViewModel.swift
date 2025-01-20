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
                guard let allMeUser = self?.convertToAllMeUser(from: user) else {
                    self?.error = "사용자 정보를 변환하는 데 실패했습니다."
                    return }
                self?.createRecord(for: allMeUser)
            }
            .store(in: &subscription)
    }
    
    /// Firestore에 사용자 정보를 저장
    func createRecord(for user: AllMeUser) {
        DatabaseManager.shared.collectionUsers(add: user)
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
    
    
    // FirebaseAuth.User를 AllMeUser로 변환하는 함수
    private func convertToAllMeUser(from user: User) -> AllMeUser {
        return AllMeUser(from: user)
    }
}
