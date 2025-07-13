import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        TabView {
            Tab("Mangas", systemImage: "book") {
                HomeView()
            }
            Tab("Saved", systemImage: "bookmark.fill") {
                MangaSavedView()
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
