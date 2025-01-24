//
//  FeedManager.swift
//  AllMe
//
//  Created by 권정근 on 1/23/25.
//

import Foundation
import CoreData
import UIKit
import Combine
//
//class FeedManager {
//    
//    static let shared = FeedManager()
//    
//    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    
//    private var feeds: [FeedItem] = []
//    
//    // MARK: - Create
//    func createFeed(_ feed: FeedItem) -> AnyPublisher<FeedItem, Error> {
//        return Future { [weak self] promise in
//            guard let self = self else { return }
//            
//            let feedModel = FeedModel(context: self.context)
//            feedModel.id = feed.id
//            feedModel.title = feed.title
//            feedModel.content = feed.contents
//            feedModel.date = feed.date
//            feedModel.imagePath = feed.imagePath.isEmpty ? nil : feed.imagePath.joined(separator: ",")
//            
//            do {
//                try self.context.save()
//                promise(.success(feed))
//                print("Feed saved successfully to CoreData.")
//            } catch {
//                promise(.failure(error))
//                print("Failed to save feed: \(error)")
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    // MARK: - Read
//    func fetchFeeds() -> AnyPublisher<[FeedItem], Error> {
//        return Future { [weak self] promise in
//            guard let self = self else { return }
//            
//            let request: NSFetchRequest<FeedModel> = FeedModel.fetchRequest()
//            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//            
//            do {
//                let results = try self.context.fetch(request)
//                let feeds = results.map { feedModel -> FeedItem in
//                    let imagePaths = feedModel.imagePath?.components(separatedBy: ",") ?? []
//                    return FeedItem(
//                        id: feedModel.id ?? UUID().uuidString,
//                        title: feedModel.title ?? "",
//                        contents: feedModel.content ?? "",
//                        date: feedModel.date ?? Date(),
//                        imagePath: imagePaths
//                    )
//                }
//                promise(.success(feeds))
//                print("Fetched \(feeds.count) feeds from CoreData.")
//            } catch {
//                promise(.failure(error))
//                print("Failed to fetch feeds: \(error)")
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    // MARK: - Update
//    func updateFeed(_ feed: FeedItem) -> AnyPublisher<FeedItem, Error> {
//        return Future { [weak self] promise in
//            guard let self = self else { return }
//            
//            let request: NSFetchRequest<FeedModel> = FeedModel.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", feed.id as CVarArg)
//            
//            do {
//                let results = try self.context.fetch(request)
//                if let feedToUpdate = results.first {
//                    feedToUpdate.title = feed.title
//                    feedToUpdate.content = feed.contents
//                    feedToUpdate.date = feed.date
//                    feedToUpdate.imagePath = feed.imagePath.isEmpty ? nil : feed.imagePath.joined(separator: ",")
//                    
//                    try self.context.save()
//                    promise(.success(feed))
//                    print("Feed updated successfully.")
//                } else {
//                    throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Feed not found."])
//                }
//            } catch {
//                promise(.failure(error))
//                print("Failed to update feed: \(error)")
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    // MARK: - Delete
//    func deleteFeed(by id: String) -> AnyPublisher<Void, Error> {
//        return Future { [weak self] promise in
//            guard let self = self else { return }
//            
//            let request: NSFetchRequest<FeedModel> = FeedModel.fetchRequest()
//            request.predicate = NSPredicate(format: "id == %@", id)
//            
//            do {
//                let results = try self.context.fetch(request)
//                if let feedToDelete = results.first {
//                    self.context.delete(feedToDelete)
//                    try self.context.save()
//                    promise(.success(()))
//                    print("Feed deleted successfully.")
//                } else {
//                    throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Feed not found."])
//                }
//            } catch {
//                promise(.failure(error))
//                print("Failed to delete feed: \(error)")
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//}


class FeedManager {
    
    static let shared = FeedManager()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // FileManager 역할 통합 (이미지 저장/삭제)
    private let storageManager = FeedStorageManager.shared
    
    // MARK: - Create
    /// images: 새로 저장할 UIImage 배열
    func createFeed(_ feed: FeedItem, images: [UIImage]) -> AnyPublisher<FeedItem, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            // 1) 우선 이미지들을 FileManager에 저장
            let savedPaths = self.storageManager.saveImages(images: images, feedID: feed.id)
            
            // 2) 저장된 이미지 경로를 feed.imagePath에 설정
            var updatedFeed = feed
            updatedFeed.imagePath = savedPaths
            
            // 3) Core Data에 저장
            let feedModel = FeedModel(context: self.context)
            feedModel.id = updatedFeed.id
            feedModel.title = updatedFeed.title
            feedModel.content = updatedFeed.contents
            feedModel.date = updatedFeed.date
            feedModel.imagePath = updatedFeed.imagePath.isEmpty ? nil : updatedFeed.imagePath.joined(separator: ",")
            
            do {
                try self.context.save()
                print("Feed + images saved successfully to CoreData.")
                promise(.success(updatedFeed)) // 성공 시, 갱신된 feed 반환
            } catch {
                print("Failed to save feed: \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Read
    func fetchFeeds() -> AnyPublisher<[FeedItem], Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            let request: NSFetchRequest<FeedModel> = FeedModel.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            do {
                let results = try self.context.fetch(request)
                let feeds = results.map { feedModel -> FeedItem in
                    let imagePaths = feedModel.imagePath?.components(separatedBy: ",") ?? []
                    return FeedItem(
                        id: feedModel.id ?? UUID().uuidString,
                        title: feedModel.title ?? "",
                        contents: feedModel.content ?? "",
                        date: feedModel.date ?? Date(),
                        imagePath: imagePaths
                    )
                }
                promise(.success(feeds))
                print("Fetched \(feeds.count) feeds from CoreData.")
            } catch {
                promise(.failure(error))
                print("Failed to fetch feeds: \(error)")
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Update
    /// images: 새로 업데이트할 UIImage 배열
    func updateFeed(_ feed: FeedItem, images: [UIImage]) -> AnyPublisher<FeedItem, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            let request: NSFetchRequest<FeedModel> = FeedModel.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", feed.id as CVarArg)
            
            do {
                let results = try self.context.fetch(request)
                if let feedToUpdate = results.first {
                    
                    // 1) 기존 이미지 삭제
                    if let oldPaths = feedToUpdate.imagePath?.components(separatedBy: ",") {
                        self.storageManager.deleteImages(from: oldPaths)
                    }
                    
                    // 2) 새 이미지 저장
                    let newPaths = self.storageManager.saveImages(images: images, feedID: feed.id)
                    
                    // 3) feedToUpdate에 새로운 정보 업데이트
                    feedToUpdate.title = feed.title
                    feedToUpdate.content = feed.contents
                    feedToUpdate.date = feed.date
                    feedToUpdate.imagePath = newPaths.isEmpty ? nil : newPaths.joined(separator: ",")
                    
                    try self.context.save()
                    
                    // 4) combine을 위해, 갱신된 feed 반환
                    var updatedFeed = feed
                    updatedFeed.imagePath = newPaths
                    print("Feed updated successfully.")
                    promise(.success(updatedFeed))
                } else {
                    throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Feed not found."])
                }
            } catch {
                promise(.failure(error))
                print("Failed to update feed: \(error)")
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Delete
    func deleteFeed(by id: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            let request: NSFetchRequest<FeedModel> = FeedModel.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let results = try self.context.fetch(request)
                if let feedToDelete = results.first {
                    
                    // 1) Core Data에 저장된 이미지 경로를 모두 삭제
                    if let pathString = feedToDelete.imagePath {
                        let paths = pathString.components(separatedBy: ",")
                        self.storageManager.deleteImages(from: paths)
                    }
                    
                    // 2) 피드를 Core Data에서 삭제
                    self.context.delete(feedToDelete)
                    try self.context.save()
                    promise(.success(()))
                    print("Feed + images deleted successfully.")
                } else {
                    throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Feed not found."])
                }
            } catch {
                promise(.failure(error))
                print("Failed to delete feed: \(error)")
            }
        }
        .eraseToAnyPublisher()
    }
}
