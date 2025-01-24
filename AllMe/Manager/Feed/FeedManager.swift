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

class FeedManager {
    
    static let shared = FeedManager()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var feeds: [FeedItem] = []
    
    // MARK: - Create
    func createFeed(_ feed: FeedItem) -> AnyPublisher<FeedItem, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            let feedModel = FeedModel(context: self.context)
            feedModel.id = feed.id
            feedModel.title = feed.title
            feedModel.content = feed.contents
            feedModel.date = feed.date
            feedModel.imagePath = feed.imagePath.isEmpty ? nil : feed.imagePath.joined(separator: ",")
            
            do {
                try self.context.save()
                promise(.success(feed))
                print("Feed saved successfully to CoreData.")
            } catch {
                promise(.failure(error))
                print("Failed to save feed: \(error)")
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
    func updateFeed(_ feed: FeedItem) -> AnyPublisher<FeedItem, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            let request: NSFetchRequest<FeedModel> = FeedModel.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", feed.id as CVarArg)
            
            do {
                let results = try self.context.fetch(request)
                if let feedToUpdate = results.first {
                    feedToUpdate.title = feed.title
                    feedToUpdate.content = feed.contents
                    feedToUpdate.date = feed.date
                    feedToUpdate.imagePath = feed.imagePath.isEmpty ? nil : feed.imagePath.joined(separator: ",")
                    
                    try self.context.save()
                    promise(.success(feed))
                    print("Feed updated successfully.")
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
                    self.context.delete(feedToDelete)
                    try self.context.save()
                    promise(.success(()))
                    print("Feed deleted successfully.")
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
    
    
    //
    //    // Create
    //    func createFeed(_ feed: FeedItem) -> AnyPublisher<FeedItem, Error> {
    //        return Future {[weak self] promise in
    //            guard let self = self else { return }
    //            self.feeds.append(feed)
    //            promise(.success(feed))    // 성공적으로 생성되면 feed 반환
    //        }
    //        .eraseToAnyPublisher()
    //    }
    //
    //
    //    // Read
    //    func fetchFeeds() -> AnyPublisher<[FeedItem], Error> {
    //        return Future { [weak self] promise in
    //            guard let self = self else { return }
    //            promise(.success(self.feeds)) // 저장된 Feed 목록 반환
    //        }
    //        .eraseToAnyPublisher()
    //    }
    //
    //
    //    // Update
    //    func updateFeed(_ feed: FeedItem) -> AnyPublisher<FeedItem, Error> {
    //        return Future { [weak self] promise in
    //            guard let self = self else { return }
    //            if let index = self.feeds.firstIndex(where: { $0.id == feed.id }) {
    //                self.feeds[index] = feed
    //                promise(.success(feed)) // 성공적으로 업데이트된 Feed 반환
    //            } else {
    //                promise(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Feed not found"])))
    //            }
    //        }
    //        .eraseToAnyPublisher()
    //    }
    //
    //
    //    // Delete
    //    func deleteFeed(by id: String) -> AnyPublisher<Void, Error> {
    //        return Future { [weak self] promise in
    //            guard let self = self else { return }
    //            self.feeds.removeAll { $0.id == id }
    //            promise(.success(())) // 성공적으로 삭제
    //        }
    //        .eraseToAnyPublisher()
    //    }
    
}
