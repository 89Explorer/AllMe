//
//  DetailViewModel.swift
//  AllMe
//
//  Created by 권정근 on 1/30/25.
//

import Foundation
import Combine
import UIKit


class DetailViewModel: ObservableObject {
    
    // DetailView가 이 값을 구독, 값이 변경될 때 UI가 업데이트 되도록 함
    @Published var feedItem: FeedItem
    @Published var images: [UIImage]
    private let feedItemViewModel: FeedItemViewModel!
    
    // DetailViewController에서 ViewModel를 생성할 때 초기 데이터 설정
    init(feedItem: FeedItem, images: [UIImage], feedItemViewModel: FeedItemViewModel) {
        self.feedItem = feedItem
        self.images = images
        self.feedItemViewModel = feedItemViewModel
    }
    
    func deleteFeed() {
        feedItemViewModel.deleteFeed(by: feedItem.id)
    }
    
    func updateFeed(title: String, content: String, images: [UIImage]) {
        // 1) feedItem을 업데이트
        feedItem.title = title
        feedItem.contents = content
        self.images = images
        
        // 2) ViewModel을 통해 수정 요청
        feedItemViewModel.updateFeed(feedItem, images: images)
        
        // UI 업데이트를 위해 feedItem을 새로 할당
        DispatchQueue.main.async {
            self.images = images
            self.feedItem = self.feedItem
        }
    }
    
}
