import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: UserViewModel
    @State private var checkInAnimation = false
    @State private var showRegularPopup = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let profile = viewModel.userProfile {
                        Text("Welcome, \(profile.username)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.top)

                        Button("Reset Visits") {
                            Task {
                                await viewModel.resetVisits()
                            }
                        }
                        .buttonStyle(.bordered)
                        .padding(.bottom)

                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                checkInAnimation = true
                            }

                            Task {
                                if let realPlace = await viewModel.generateNearbyPlace() {
                                    let previousVisits = viewModel.userProfile?.visitedPlaces.first(where: { $0.id == realPlace.id })?.visits ?? 0

                                    await viewModel.logVisit(to: realPlace)

                                    let updatedVisits = viewModel.userProfile?.visitedPlaces.first(where: { $0.id == realPlace.id })?.visits ?? 0
                                    if previousVisits < 3 && updatedVisits >= 3 {
                                        showRegularPopup = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                            showRegularPopup = false
                                        }
                                    }

                                    // Optional debug print
                                    print("checked into \(realPlace.name) — Visits: \(updatedVisits)")
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    checkInAnimation = false
                                }
                            }
                        }) {
                            Image(systemName: checkInAnimation ? "checkmark.circle.fill" : "plus.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.orange)
                                .scaleEffect(checkInAnimation ? 1.2 : 1.0)
                        }
                        .padding()

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(profile.visitedPlaces) { place in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(place.name)
                                        .font(.headline)
                                    Text("Visits: \(place.visits)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel.deleteVisitedPlace(place)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    } else {
                        ProgressView("Loading profile...")
                            .padding()
                    }
                }
                .padding(.bottom)
            }
            .overlay(
                Group {
                    if showRegularPopup {
                        Text("🎉 You're now a regular here!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1)
                    }
                },
                alignment: .top
            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.orange)
                        Text("Tracker")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
            }
        }
    }
}
