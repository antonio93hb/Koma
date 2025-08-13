//
//  PreviewSupport.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 12/8/25.
//

#if DEBUG
import SwiftUI
import SwiftData

/// Contenedor genérico para previews que:
/// - Crea el modelContainer en memoria (MangaDB + SearchDB)
/// - Inyecta MangaViewModel(NetworkTest) y SearchViewModel()
/// - Pasa el modelContext al SearchViewModel
struct PreviewBootstrap<Content: View>: View {
    @Environment(\.modelContext) private var context

    private let content: () -> Content
    private let mangaVM = MangaViewModel(network: NetworkTest())
    private let searchVM = SearchViewModel(network: NetworkTest())

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .environment(mangaVM)
            .environment(searchVM)
            .task {
                if searchVM.context == nil { searchVM.context = context }
                await mangaVM.loadIfNeeded()
            }
    }
}

/// Atajo para añadir el modelContainer en memoria usado por la app.
extension View {
    func previewModelContainer() -> some View {
        self.modelContainer(for: [MangaDB.self, SearchDB.self], inMemory: true)
    }
}
#endif
