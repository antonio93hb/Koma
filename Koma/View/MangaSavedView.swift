import SwiftUI

struct MangaSavedView: View {
    
    @Environment(MangaViewModel.self) var viewModel
    @State private var selectedManga: Manga? = nil
    
    var body: some View {
        NavigationStack {
            if viewModel.savedMangas.isEmpty {
                VStack(spacing: 16){
                    Image(systemName: "bookmark.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.gray.opacity(0.5))
                    Text("No saved mangas yet.")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Text("Swipe on a manga to save it for later.")
                        .font(.subheadline)
                        .foregroundStyle(.gray.opacity(0.6))
                        .padding(.horizontal, 30)
                }
            }  else {
                List {
                    ForEach(viewModel.savedMangas, id: \.id) { manga in
                        MangaRow(
                            manga: manga,
                            ownedVolumeText: "Tomos: \(manga.ownedVolumes ?? 0) / \(manga.volumes ?? 0)"
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedManga = manga
                        }
                        .listRowSeparator(.visible)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let mangaToRemove = viewModel.savedMangas[index]
                            Task {
                                try await viewModel.unSaveManga(mangaToRemove)
                                await viewModel.getSavedMangas()
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Guardados")
                .navigationDestination(item: $selectedManga) { manga in
                    MangaDetailView(manga: manga)
                }
                
                let totalOwned = viewModel.savedMangas.compactMap(\.ownedVolumes).reduce(0, +)
                let totalVolumes = viewModel.savedMangas.compactMap(\.volumes).reduce(0, +)
                
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemBackground))
                    .frame(height: 60)
                    .overlay(
                        HStack(spacing: 16) {
                            Label("Guardados: \(viewModel.savedMangas.count)", systemImage: "bookmark.fill")
                            Label("Tomos: \(totalOwned) / \(totalVolumes)", systemImage: "books.vertical")
                        }
                        .font(.footnote)
                        .foregroundStyle(.primary)
                        .padding(.horizontal)
                    )
                    .padding()
                    .shadow(radius: 4)
            }
        }
        .onAppear {
            Task {
                await viewModel.getSavedMangas()
            }
        }
    }
}

#Preview {
    let testViewModel = MangaViewModel(network: NetworkTest())
    return MangaSavedView()
        .environment(testViewModel)
}
