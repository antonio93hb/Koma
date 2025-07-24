
import SwiftUI

struct MangaSavedView: View {
    
    @Environment(MangaViewModel.self) var viewModel
    @State private var savedMangas: [Manga] = []
    @State private var selectedManga: Manga? = nil
    
    var body: some View {
        NavigationStack {
            if savedMangas.isEmpty {
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
                    ForEach(savedMangas, id: \.id) { manga in
                        MangaRow(manga: manga)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedManga = manga
                            }
                            .listRowSeparator(.visible)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let mangaToRemove = savedMangas[index]
                            Task {
                                try await viewModel.unSaveManga(mangaToRemove)
                                savedMangas = await viewModel.getSavedMangas()
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Guardados")
                .navigationDestination(item: $selectedManga) { manga in
                    MangaDetailView(manga: manga)
                }
            }
        }
        .task {
            savedMangas = await viewModel.getSavedMangas()
        }
    }
}

#Preview {
    let testViewModel = MangaViewModel(network: NetworkTest())
    return MangaSavedView()
        .environment(testViewModel)
}
