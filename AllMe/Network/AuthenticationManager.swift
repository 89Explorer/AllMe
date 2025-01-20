//
//  AuthenticationManager.swift
//  AllMe
//
//  Created by 권정근 on 1/19/25.
//

import Foundation
import FirebaseAuth
import Combine

final class AuthenticationManager {
    
    
    static let shared = AuthenticationManager()
    
    private init() {}
    
    /// Facebook 등의 소셜 로그인 처리
    func signIn(with credential: AuthCredential) -> AnyPublisher<User, Error> {
        
        return Future { promise in
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    promise(.failure(error))  // 에러 처리
                } else  if let user = authResult?.user {
                    promise(.success(user))   // 성공
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
