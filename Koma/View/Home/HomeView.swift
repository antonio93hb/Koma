import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(MangaViewModel.self) var viewModel
    @State private var isGridMode = false

    var body: some View {
        NavigationStack {
            if viewModel.isLoading && viewModel.mangas.isEmpty {
                ProgressView("Loading mangas...")
            } else {
                Group {
                    if isGridMode {
                        ScrollView {
                            mainContent(body: gridSection)
                        }
                    } else {
                        List {
                            mainContent(body: listSection)
                        }
                        .listStyle(.plain)
                    }
                }
                .navigationTitle("Descubrir")
            }
        }
    }
    
    @ViewBuilder
    private func mainContent(body: some View) -> some View {
        CarruselSectionView()
            .padding(.horizontal)

        HStack {
            Text("Popular")
            Spacer()
            toggleViewButton
        }
        .padding(.horizontal)

        body

        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
        }
    }

    private var toggleViewButton: some View {
        Button {
            isGridMode.toggle()
        } label: {
            Image(systemName: isGridMode ? "list.bullet" : "square.grid.2x2")
        }
    }

    private var listSection: some View {
        ForEach(viewModel.mangas) { manga in
            NavigationLink(destination: MangaDetailView(manga: manga)) {
                MangaRow(manga: manga, showSavedIcon: true)
                    .onAppear {
                        Task {
                            await viewModel.loadMoreIfNeeded(current: manga)
                        }
                    }
            }
        }
    }

    private var gridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(viewModel.mangas) { manga in
                NavigationLink(destination: MangaDetailView(manga: manga)) {
                    MangaImg(manga: manga)
                        .frame(height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.primary, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
                .onAppear {
                    Task {
                        await viewModel.loadMoreIfNeeded(current: manga)
                    }
                }            }
        }
        .padding(.horizontal)
        .padding(.vertical)
    }
}

#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    var body: some View {
        let testViewModel = MangaViewModel(network: NetworkTest())
        HomeView()
            .environment(testViewModel)
            .task {
                await testViewModel.loadIfNeeded()
            }
    }
}
