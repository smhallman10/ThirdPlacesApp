//
//  UserProfile.swift
//  ThirdPlaces
//
//  Created by William Hallman on 4/17/25.
//

struct UserProfile: Codable, Identifiable {
    var id: String
    var username: String
    var visitedPlaces: [VisitedPlace]
    var profileImageUrl: String?
    var age: String?
    var gender: String?
    var hobbies: String?
    var profileSymbol: String?
}
