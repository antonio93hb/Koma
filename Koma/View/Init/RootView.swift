import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(RootManager.self) var rootManager
    @Environment(\.modelContext) private var modelContext
    
    //@State private var viewModel = MangaListViewModel()
    @Environment(MangaViewModel.self) var viewModel

    var body: some View {
        Group {
            switch rootManager.currentView {
            case .welcome: WelcomeView()
            case .login: LoginView()
            case .content: ContentView()
            }
        }
        .task {
            if viewModel.context == nil {
                viewModel.context = modelContext
                await viewModel.loadIfNeeded()
            }
        }
    }
}

