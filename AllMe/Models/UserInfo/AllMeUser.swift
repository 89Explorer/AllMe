//
//  AllMeUser.swift
//  AllMe
//
//  Created by 권정근 on 1/20/25.
//

import Foundation
import FirebaseAuth
import Firebase


struct AllMeUser: Codable {
    
    let id: String
    var displayName: String = ""
    var userName: String = ""
    var createOn: Date = Date()
    var bio: String = ""
    var avatarPath: String = ""
    
    // 기본 초기화
    // Facebook 데이터를 저장하기 위한 초기화 확장 
    init(from user: User, displayName: String = "", userName: String = "", bio: String = "", avatarPath: String = "") {
        self.id = user.uid
        self.displayName = displayName
        self.userName = userName
        self.createOn = Date()
        self.bio = bio
        self.avatarPath = avatarPath
    }
}
