//
//  FeedItemViewModel.swift
//  AllMe
//
//  Created by 권정근 on 1/23/25.
//

import Foundation
import Combine

class FeedItemViewModel: ObservableObject {
    
    // 1) 현재 작성 중인 단일 피드
    @Published var userFeed: FeedItem = FeedItem(id: "")
    
    // 2) 이미 저장된 피드 목록
    @Published var feeds: [FeedItem] = []
    
    // 3) 에러 메시지 등을 표시하기 위한 프로퍼티
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // CoreData, Combine 등을 다루는 매니저 (기존 코드를 재사용)
    private let feedManager = FeedManager.shared
    
    
    func createFeed(_ feed: FeedItem) {
        feedManager.createFeed(feed)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] feed in
                print("Successfully saved feed: \(feed)")
                self?.feeds.append(feed)
                
                // 저장 후, 새 피드 작성 목적으로 치고화
                self?.userFeed = FeedItem(id: "")
            })
            .store(in: &cancellables)
    }
    
    
    func fetchFeeds() {
        feedManager.fetchFeeds()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] feeds in
                self?.feeds = feeds
                print("feed 정보: \(feeds)")
            })
            .store(in: &cancellables)
    }
    
    
    func updateFeed(_ feed: FeedItem) {
        feedManager.updateFeed(feed)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] updatedFeed in
                if let index = self?.feeds.firstIndex(where: { $0.id == updatedFeed.id }) {
                    self?.feeds[index] = updatedFeed
                }
                print("Successfully updated feed: \(updatedFeed)")
            })
            .store(in: &cancellables)
    }
    
    
    func deleteFeed(by id: String) {
        feedManager.deleteFeed(by: id)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] in
                self?.feeds.removeAll { $0.id == id }
                print("Successfully deleted feed with ID: \(id)")
            })
            .store(in: &cancellables)
    }
}

