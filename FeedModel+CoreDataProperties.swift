//
//  FeedModel+CoreDataProperties.swift
//  AllMe
//
//  Created by 권정근 on 1/24/25.
//
//

import Foundation
import CoreData


extension FeedModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedModel> {
        return NSFetchRequest<FeedModel>(entityName: "FeedModel")
    }

    @NSManaged public var content: String?
    @NSManaged public var date: Date?
    @NSManaged public var title: String?
    @NSManaged public var imagePath: String?
    @NSManaged public var id: String?

}

extension FeedModel : Identifiable {

}
