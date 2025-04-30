//
//  LeaderboardViewModel.swift
//  ThirdPlaces
//
//  Created by William Hallman on 4/28/25.
//

import Foundation
import FirebaseFirestore

@MainActor
class LeaderboardViewModel: ObservableObject {
    @Published var users: [UserProfile] = []
    
    private var db = Firestore.firestore()
    
    init() {
        Task {
            await fetchUsers()
        }
    }
    
    func fetchUsers() async {
        do {
            let snapshot = try await db.collection("users").getDocuments()
            self.users = snapshot.documents.compactMap { try? $0.data(as: UserProfile.self) }
        } catch {
            print("Error fetching users: \(error.localizedDescription)")
        }
    }
    
    var leaderboardEntries: [LeaderboardEntry] {
        users.map { user in
            let regularPlaces = user.visitedPlaces.filter { $0.visits >= 3 }
            return LeaderboardEntry(
                username: user.username,
                regularCount: regularPlaces.count,
                profileImageUrl: user.profileImageUrl
            )
        }
        .sorted { $0.regularCount > $1.regularCount }
    }

}
