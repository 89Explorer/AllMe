//
//  DatabaseManager.swift
//  AllMe
//
//  Created by 권정근 on 1/20/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import Combine



class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private init() {}
    
    let db = Firestore.firestore()
    let userPath: String = "users"
    
    func collectionUsers(add user: AllMeUser) -> AnyPublisher<Bool, Error> {
        
        // FireStore에 데이터 저장
        return db.collection(userPath).document(user.id)
            .setData(from: user)
            .handleEvents(receiveSubscription: { _ in
                print("Firestore 작업 시작: \(user.id)")
            }, receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Firestore 작업 실패: \(error.localizedDescription)")
                case .finished:
                    print("Firestore 작업 성공")
                }
            })
            .map { _ in
                return true
            }
            .eraseToAnyPublisher()
    }
    
    
    
    
}
