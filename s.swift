//
//  VistedPlaceEntity+CoreDataProperties.swift
//  ThirdPlaces
//
//  Created by William Hallman on 4/29/25.
//
//

import Foundation
import CoreData


extension VistedPlaceEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VistedPlaceEntity> {
        return NSFetchRequest<VistedPlaceEntity>(entityName: "VistedPlaceEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var visits: Int16
    @NSManaged public var lastVIsited: Date?

}

extension VistedPlaceEntity : Identifiable {

}
