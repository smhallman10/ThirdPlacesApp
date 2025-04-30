import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@MainActor
class UserViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userProfile: UserProfile?
    @Published var location: CLLocation?

    private var db = Firestore.firestore()
    private var locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        Task { await authenticateUser() }
    }

    func authenticateUser() async {
        do {
            let result = try await Auth.auth().signInAnonymously()
            await fetchUserProfile(userId: result.user.uid)
        } catch {
            print("Authentication error: \(error.localizedDescription)")
        }
    }

    func fetchUserProfile(userId: String) async {
        let docRef = db.collection("users").document(userId)
        do {
            let snapshot = try await docRef.getDocument()
            if snapshot.exists {
                userProfile = try snapshot.data(as: UserProfile.self)
            } else {
                let newProfile = UserProfile(id: userId, username: "Guest", visitedPlaces: [])
                userProfile = newProfile
                try docRef.setData(from: newProfile)
            }
        } catch {
            print("Error fetching user profile: \(error.localizedDescription)")
        }
    }

    func updateUserProfile(
        username: String,
        visitedPlaces: [VisitedPlace],
        age: String? = nil,
        gender: String? = nil,
        hobbies: String? = nil,
        profileSymbol: String? = nil
    ) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var profile = userProfile ?? UserProfile(id: uid, username: "Guest", visitedPlaces: [])

        profile.username = username
        profile.visitedPlaces = visitedPlaces
        if let age = age { profile.age = age }
        if let gender = gender { profile.gender = gender }
        if let hobbies = hobbies { profile.hobbies = hobbies }
        if let profileSymbol = profileSymbol { profile.profileSymbol = profileSymbol }

        do {
            try db.collection("users").document(uid).setData(from: profile)
            userProfile = profile
        } catch {
            print("Error updating user profile: \(error.localizedDescription)")
        }
    }

    func logVisit(to place: VisitedPlace) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var profile = userProfile ?? UserProfile(id: uid, username: "Guest", visitedPlaces: [])

        if let index = profile.visitedPlaces.firstIndex(where: { $0.id == place.id }) {
            profile.visitedPlaces[index].visits += 1
            profile.visitedPlaces[index].lastVisited = Date()
        } else {
            var newPlace = place
            newPlace.visits = 1
            newPlace.lastVisited = Date()
            profile.visitedPlaces.append(newPlace)
        }

        do {
            try db.collection("users").document(uid).setData(from: profile)
            userProfile = profile
        } catch {
            print("Error saving profile: \(error.localizedDescription)")
        }
    }

    func resetVisits() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var profile = userProfile ?? UserProfile(id: uid, username: "Guest", visitedPlaces: [])

        for index in profile.visitedPlaces.indices {
            profile.visitedPlaces[index].visits = 0
        }

        do {
            try db.collection("users").document(uid).setData(from: profile)
            userProfile = profile
            await fetchUserProfile(userId: uid)
        } catch {
            print("Error resetting visits: \(error.localizedDescription)")
        }
    }

    func deleteVisitedPlace(_ place: VisitedPlace) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var profile = userProfile ?? UserProfile(id: uid, username: "Guest", visitedPlaces: [])

        profile.visitedPlaces.removeAll { $0.id == place.id }

        do {
            try db.collection("users").document(uid).setData(from: profile)
            userProfile = profile

        } catch {
            print("Error deleting place: \(error.localizedDescription)")
        }
    }

    func generateNearbyPlace() async -> VisitedPlace? {
        guard let location = location else { return nil }
        let name = await getNearbyPlaceName()

        return VisitedPlace(
            id: "place_\(Int(location.coordinate.latitude * 1000))_\(Int(location.coordinate.longitude * 1000))",
            name: name,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            visits: 0
        )
    }

    func getNearbyPlaceName() async -> String {
        guard let location = location else {
            print("No location available")
            return "Unknown Location"
        }

        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let place = placemarks.first {
                if let name = place.name,
                   !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: String(name.prefix(1))))
                {
                    print("probably a business: \(name)")
                    return name
                } else {
                    print("probably an address: \(place.name ?? "nil") — skipping")
                    return "Unnamed Establishment"
                }
            } else {
                print("no placemarks found")
                return "Unknown Location"
            }
        } catch {
            print("geocoding failed: \(error.localizedDescription)")
            return "Unknown Location"
        }
    }

    func uploadProfileImage(_ data: Data) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let storageRef = Storage.storage().reference().child("profilePictures/\(uid).jpg")
            _ = try await storageRef.putDataAsync(data, metadata: nil)
            let downloadURL = try await storageRef.downloadURL()
            var profile = userProfile ?? UserProfile(id: uid, username: "Guest", visitedPlaces: [])
            profile.profileImageUrl = downloadURL.absoluteString
            try db.collection("users").document(uid).setData(from: profile)
            userProfile = profile
        } catch {
            print("Failed to upload profile picture: \(error.localizedDescription)")
        }
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        location = latest
        print("📍 Location updated to: \(latest.coordinate.latitude), \(latest.coordinate.longitude)")
    }
}
