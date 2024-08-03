//
//  HotProspectsApp.swift
//  HotProspects
//
//  Created by Ayrton Parkinson on 2024/08/02.
//

import SwiftUI
import SwiftData

@main
struct HotProspectsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Prospect.self)
    }
}
