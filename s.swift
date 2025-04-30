//
//  s.swift
//  ThirdPlaces
//
//  Created by William Hallman on 4/29/25.
//
//

import CoreData
import Foundation

public extension VistedPlaceEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<VistedPlaceEntity> {
        return NSFetchRequest<VistedPlaceEntity>(entityName: "VistedPlaceEntity")
    }

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var visits: Int16
    @NSManaged var lastVIsited: Date?
}

extension VistedPlaceEntity: Identifiable {}
