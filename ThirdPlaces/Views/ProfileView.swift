import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: UserViewModel
    @State private var newUsername: String = ""
    @State private var age: String = ""
    @State private var gender: String = "Select Gender"
    @State private var hobbies: String = ""
    @State private var profileSymbol: String = "person.fill"

    let symbolChoices = ["person.fill", "leaf.fill", "flame.fill", "bolt.fill", "star.fill", "bicycle", "book.fill", "gamecontroller.fill", "globe", "music.note"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if let profile = viewModel.userProfile {
                        Text("Choose an Icon")
                            .font(.headline)

                        // SF Symbol Picker Grid
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                            ForEach(symbolChoices, id: \.self) { symbol in
                                Image(systemName: symbol)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                    .padding()
                                    .background(profileSymbol == symbol ? Color.orange.opacity(0.3) : Color.clear)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        profileSymbol = symbol
                                    }
                            }
                        }
                        .padding(.horizontal)

                        // Display chosen icon
                        Image(systemName: profileSymbol)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 6)

                        Text(profile.username)
                            .font(.title)
                            .bold()
                            .padding(.top)

                        VStack(spacing: 12) {
                            TextField("New username...", text: $newUsername)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)

                            TextField("Age", text: $age)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)

                            Picker("Gender", selection: $gender) {
                                Text("Select Gender").tag("Select Gender")
                                Text("Male").tag("Male")
                                Text("Female").tag("Female")
                                Text("Other").tag("Other")
                            }
                            .pickerStyle(MenuPickerStyle())

                            TextField("Tell us about your hobbies...", text: $hobbies)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding(.horizontal)

                        Button("Update Profile") {
                            Task {
                                await viewModel.updateUserProfile(
                                    username: newUsername.isEmpty ? profile.username : newUsername,
                                    visitedPlaces: profile.visitedPlaces,
                                    age: age,
                                    gender: gender,
                                    hobbies: hobbies,
                                    profileSymbol: profileSymbol
                                )
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    } else {
                        ProgressView("Loading profile...")
                    }
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let profile = viewModel.userProfile {
                    newUsername = profile.username
                    age = profile.age ?? ""
                    gender = profile.gender ?? "Select Gender"
                    hobbies = profile.hobbies ?? ""
                    profileSymbol = profile.profileSymbol ?? "person.fill"
                }
            }
        }
    }
}
