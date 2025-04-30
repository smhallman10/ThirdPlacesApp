//
//  VisitedPlace.swift
//  ThirdPlaces
//
//  Created by William Hallman on 4/17/25.
//

import Foundation

struct VisitedPlace: Codable, Identifiable {
    var id: String
    var name: String
    var latitude: Double
    var longitude: Double
    var visits: Int
    var lastVisited: Date? = nil
}

struct GooglePlacesResponse: Codable {
    let results: [PlaceResult]
}

struct PlaceResult: Codable {
    let place_id: String
    let name: String
    let geometry: Geometry
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}
