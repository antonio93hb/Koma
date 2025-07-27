import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        TabView {
            Tab("Mangas", systemImage: "text.book.closed.fill") {
                HomeView()
            }
            Tab("Collection", systemImage: "books.vertical.fill") {
                MangaCollectionView()
            }
        }
        .tint(colorScheme == .dark ? .white : .black)
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    ContentView()
        .environment(RootManager())
}
