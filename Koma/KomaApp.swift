//
//  KomaApp.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 20/6/25.
//

import SwiftUI
import SwiftData

@main
struct KomaApp: App {
    @State private var rootManager = RootManager()
    @State private var mangaListViewModel = MangaViewModel()
    @State private var searchViewModel = SearchViewModel()

    var sharedModelContainer: ModelContainer {
        let schema = Schema([MangaDB.self])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: modelConfiguration)
        } catch {
            fatalError("No se pudo crear el model container \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(rootManager)
                .environment(mangaListViewModel)
                .environment(searchViewModel)
        }
        .modelContainer(sharedModelContainer)
    }
}
