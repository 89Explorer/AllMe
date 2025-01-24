//
//  FeedItem.swift
//  AllMe
//
//  Created by 권정근 on 1/23/25.
//

import Foundation
import UIKit

struct FeedItem: Codable {
    var id: String
    var title: String? = ""
    var contents: String? = ""
    var date: Date? = Date()
    var imagePath: [String] = []
}


