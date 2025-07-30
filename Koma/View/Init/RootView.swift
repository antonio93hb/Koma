import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(RootManager.self) var rootManager
    @Environment(\.modelContext) private var modelContext
    
    @Environment(MangaViewModel.self) var mangaViewModel
    @Environment(SearchViewModel.self) var searchViewModel

    var body: some View {
        Group {
            switch rootManager.currentView {
            case .welcome: WelcomeView()
            case .login: LoginView()
            case .content: ContentView()
            }
        }
        .task {
            if mangaViewModel.context == nil {
                mangaViewModel.context = modelContext
                await mangaViewModel.loadIfNeeded()
            }
            if searchViewModel.context == nil {
                searchViewModel.context = modelContext
                await searchViewModel.loadSearchHistory()
            }
        }
    }
}

