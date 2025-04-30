//
//  LeaderboardEntry.swift
//  ThirdPlaces
//
//  Created by William Hallman on 4/28/25.
//

import Foundation

struct LeaderboardEntry: Identifiable {
    var id = UUID()
    var username: String
    var regularCount: Int
    var profileImageUrl: String?
}
