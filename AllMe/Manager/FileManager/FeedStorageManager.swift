//
//  FeedFileManager.swift
//  AllMe
//
//  Created by 권정근 on 1/24/25.
//

import Foundation
import UIKit


class FeedStorageManager {
    
    static let shared = FeedStorageManager()
    private let fileManager = FileManager.default
    
    /// Documents 폴더 경로 가져오기
    private func getDocumentsDirectory() -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// 이미지를 저장하고 경로를 반환하는 함수
    func saveImages(images: [UIImage], feedID: String) -> [String] {
        let feedFolder = getDocumentsDirectory().appendingPathComponent(feedID)
        
        // ✅ 기존 이미지 삭제
        if FileManager.default.fileExists(atPath: feedFolder.path) {
            try? FileManager.default.removeItem(at: feedFolder)
        }
        
        try? FileManager.default.createDirectory(at: feedFolder, withIntermediateDirectories: true, attributes: nil)
        
        var savedImagesPaths: [String] = []
        
        for (index, image) in images.enumerated() {
            let fileName = "image_\(index).jpg"
            let fileURL = feedFolder.appendingPathComponent(fileName)
            
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                try? imageData.write(to: fileURL)
                savedImagesPaths.append("\(feedID)/\(fileName)")
            }
        }
        return savedImagesPaths
    }
    //    func saveImages(images: [UIImage], feedID: String) -> [String] {
    //
    //        let feedFolder = getDocumentsDirectory().appendingPathComponent(feedID)
    //
    //        // 폴더가 없다면? 생성
    //        if !FileManager.default.fileExists(atPath: feedFolder.path) {
    //            try? FileManager.default.createDirectory(at: feedFolder,
    //                                                     withIntermediateDirectories: true,
    //                                                     attributes: nil)
    //        }
    //
    //        var savedImagesPaths: [String] = []
    //
    //        for (index, image) in images.enumerated() {
    //            let fileName = "image_\(index).jpg"
    //            let fileURL = feedFolder.appendingPathComponent(fileName)
    //
    //            if let imageData = image.jpegData(compressionQuality: 1.0) {
    //                try? imageData.write(to: fileURL)
    //
    //                // feedID/파일명 형태의 상대 경로 저장
    //                savedImagesPaths.append("\(feedID)/\(fileName)")
    //            }
    //        }
    //        return savedImagesPaths
    //    }
    
    /// 저장한 이미지를 상대경로로 불러옴
    func loadImages(from relativePaths: [String]) -> [UIImage] {
        
        var images: [UIImage] = []
        
        for relativePath in relativePaths {
            let fullPath = getDocumentsDirectory().appendingPathComponent(relativePath)
            if let image = UIImage(contentsOfFile: fullPath.path) {
                images.append(image)
            }
        }
        // print("load image: \(images)")
        return images
    }
    
    /// 저장한 이미지를 삭제하는 함수
    func deleteImages(from relativePaths: [String]) {
        for relativePath in relativePaths {
            let fullPath = getDocumentsDirectory().appendingPathComponent(relativePath)
            
            do {
                try fileManager.removeItem(at: fullPath)
                print("Deleted image at: \(fullPath.path)")
            } catch {
                print("Failed to delete image at: \(fullPath.path). Error: \(error)")
            }
        }
    }
}
