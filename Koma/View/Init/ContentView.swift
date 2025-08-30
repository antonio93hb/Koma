import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        TabView {
            Tab("mangas", systemImage: "text.book.closed.fill") {
                HomeView()
            }
            Tab("collection", systemImage: "books.vertical.fill") {
                MangaCollectionView()
            }
            Tab("search", systemImage: "magnifyingglass") {
                MangaSearchView()
            }
        }
        .tint(colorScheme == .dark ? .white : .black)
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    PreviewBootstrap { ContentView() }
        .previewModelContainer()
}
