import SwiftUI

struct MangaCollectionView: View {
    
    @Environment(MangaViewModel.self) var viewModel
    @State private var selectedManga: Manga? = nil
    
    // Altura y desvanecido del encabezado — iguales que en Home
    private let headerHeight: CGFloat = 500
    private let fadeDistance: CGFloat = 120
    
    var body: some View {
        NavigationStack {
            // Imagen para el fondo borroso: primer guardado o aleatorio si no hay
            let bgURL = viewModel.savedMangas.first?.imageURL ?? viewModel.mangas.randomElement()?.imageURL

            GeometryReader { geo in
                ZStack(alignment: .top) {
                    // Capa base
                    Color(.systemBackground)
                        .ignoresSafeArea()

                    if let bgURL {
                        BlurredBackground(
                            imageURL: bgURL,
                            blur: 24,
                            opacity: 0.18,
                            height: geo.size.height * 0.45,
                            fadeDistance: fadeDistance + 16,
                            showTopShadow: false
                        )
                        .allowsHitTesting(false)
                        .ignoresSafeArea(edges: .top)
                        .zIndex(0)
                    }

                    // --- CONTENIDO ---
                    List {

                        if viewModel.savedMangas.isEmpty {
                            // Estado vacío centrado
                            VStack(spacing: 16) {
                                Image(systemName: "bookmark.slash")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(.gray.opacity(0.5))
                                Text("collection_empty_title")
                                    .font(.title3).fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                Text("collection_empty_subtitle")
                                    .font(.subheadline)
                                    .foregroundStyle(.gray.opacity(0.6))
                                    .padding(.horizontal, 30)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .listRowBackground(Color.clear)
                        } else {
                            Section {
                                ForEach(viewModel.savedMangas) { manga in
                                    MangaRow(
                                        manga: manga,
                                        ownedVolumeText: "volumes_label \(manga.ownedVolumes ?? 0) \(manga.volumes ?? 0)"
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture { selectedManga = manga }
                                }
                                .onDelete { indexSet in
                                    Task {
                                        for idx in indexSet {
                                            let m = viewModel.savedMangas[idx]
                                            try? await viewModel.unSaveManga(m)
                                        }
                                        await viewModel.getSavedMangas()
                                    }
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listRowBackground(Color.clear)
                    .zIndex(1)
                }
            }
            .navigationTitle("collection")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedManga) { manga in
                MangaDetailView(manga: manga)
            }
            // Resumen inferior fijo sobre la barra
            .safeAreaInset(edge: .bottom) {
                let totalOwned = viewModel.savedMangas.compactMap(\ .ownedVolumes).reduce(0, +)
                let totalVolumes = viewModel.savedMangas.compactMap(\ .volumes).reduce(0, +)

                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
                    .frame(height: 60)
                    .overlay(
                        HStack(spacing: 16) {
                            Label("saved: \(viewModel.savedMangas.count)", systemImage: "bookmark.fill")
                            Label("volumes_label \(totalOwned) \(totalVolumes)", systemImage: "books.vertical")
                        }
                        .font(.footnote)
                        .foregroundStyle(.primary)
                        .padding(.horizontal)
                    )
                    .padding([.horizontal, .top])
            }
        }
        .onAppear { Task { await viewModel.getSavedMangas() } }
    }
}

#Preview {
    let testViewModel = MangaViewModel(network: NetworkTest())
    return MangaCollectionView()
        .environment(testViewModel)
}
