import FirebaseAuth
import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var viewModel: UserViewModel

    var body: some View {
        NavigationView {
            List {
                if let profile = viewModel.userProfile {
                    Section(header: Text("Regular Status")) {
                        let regularPlaces = viewModel.userProfile?.visitedPlaces.filter { $0.visits >= 3 } ?? []

                        if regularPlaces.isEmpty {
                            Text("No regular spots yet.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(regularPlaces) { place in
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    VStack(alignment: .leading) {
                                        Text(place.name)
                                            .font(.headline)
                                        Text("Visits: \(place.visits)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }

                    ForEach(profile.visitedPlaces) { place in
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading) {
                                Text(place.name)
                                    .font(.headline)
                                Text("Visited: \(place.visits) times")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task {
                                    await delete(place: place)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } else {
                    Text("No visit history available.")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("History")
        }
    }

    func delete(place: VisitedPlace) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var profile = viewModel.userProfile ?? UserProfile(id: uid, username: "Guest", visitedPlaces: [])
        profile.visitedPlaces.removeAll { $0.id == place.id }
        await viewModel.updateUserProfile(username: profile.username, visitedPlaces: profile.visitedPlaces)
    }
}
