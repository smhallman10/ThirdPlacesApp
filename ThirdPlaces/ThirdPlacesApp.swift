//
//  ThirdPlacesApp.swift
//  ThirdPlaces
//
//  Created by William Hallman on 4/16/25.
//
import SwiftUI
import Firebase
import FirebaseAppCheck


@main
struct ThirdPlacesApp: App {

    init() {
        #if DEBUG
        UserDefaults.standard.set("C96AA2A1-6546-4D5F-AC15-7289A157EACD", forKey: "FirebaseAppCheckDebugToken")
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #endif

        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
