import WidgetKit
import SwiftUI
import Firebase
import FirebaseAuth

// Define the data model
struct VisitedPlace: Identifiable {
    var id: String
    var name: String
    var visits: Int
}

struct Provider: TimelineProvider {
    // Placeholder data for the widget
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), visitedPlaces: [VisitedPlace(id: "1", name: "Coffee Shop", visits: 5), VisitedPlace(id: "2", name: "Gym", visits: 3)])
    }

    // Fetching snapshot data (will be used to display widget during development)
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let sampleData = [VisitedPlace(id: "1", name: "Coffee Shop", visits: 5), VisitedPlace(id: "2", name: "Gym", visits: 3)]
        completion(SimpleEntry(date: Date(), visitedPlaces: sampleData))
    }

    // Fetching data from Firebase for the widget timeline
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
            .getDocument { document, error in
                if let document = document, document.exists {
                    let placesData = document.get("visitedPlaces") as? [[String: Any]] ?? []
                    let visitedPlaces = placesData.map { place -> VisitedPlace in
                        let id = place["id"] as? String ?? ""
                        let name = place["name"] as? String ?? ""
                        let visits = place["visits"] as? Int ?? 0
                        return VisitedPlace(id: id, name: name, visits: visits)
                    }

                    let entry = SimpleEntry(date: Date(), visitedPlaces: visitedPlaces)
                    let timeline = Timeline(entries: [entry], policy: .atEnd)
                    completion(timeline)
                } else {
                    print("Error fetching Firebase document: \(String(describing: error))")
                }
            }
    }
}

// Widget entry data
struct SimpleEntry: TimelineEntry {
    let date: Date
    let visitedPlaces: [VisitedPlace]
}

// Widget View
struct VisitedPlacesWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Visited Places")
                .font(.headline)
                .padding(.bottom, 5)

            ForEach(entry.visitedPlaces) { place in
                HStack {
                    Text(place.name)
                        .font(.body)
                    Spacer()
                    Text("Visits: \(place.visits)")
                        .font(.body)
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
    }
}

// Widget Main Structure
@main
struct VisitedPlacesWidget: Widget {
    let kind: String = "VisitedPlacesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            VisitedPlacesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Visited Places")
        .description("Shows your most recent visited places.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
