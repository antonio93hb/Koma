import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(MangaViewModel.self) var viewModel
    @State private var isGridMode = false
    /// URL (String) de la portada centrada en el carrusel para pintar el fondo borroso
    @State private var focusedCoverURL: String?
    @State private var carouselFrame: CGRect = .zero
    private let headerHeight: CGFloat = 220

    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo base para toda la vista
                Color(.systemBackground).ignoresSafeArea()
                
                // Contenido principal
                if viewModel.isLoading && viewModel.mangas.isEmpty {
                    ProgressView("Loading mangas...")
                } else {
                    ScrollView {
                        ZStack(alignment: .top) {
                            // Fondo borroso anclado al carrusel: se mueve junto al contenido
                            CarouselBlurOverlay(
                                imageURL: focusedCoverURL,
                                anchorFrame: carouselFrame,
                                fallbackHeight: headerHeight,
                                verticalPadding: 120,
                                opacity: 0.18
                            )
                            // Contenido
                            VStack(alignment: .leading, spacing: 16) {
                                CarruselSectionView()
                                    .padding(.top, 4)
                                    .zIndex(1)

                                HStack {
                                    Text("Popular")
                                    Spacer()
                                    toggleViewButton
                                }
                                .padding(.horizontal)

                                if isGridMode {
                                    gridSection
                                } else {
                                    listSection
                                }

                                if viewModel.isLoading {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .zIndex(1)
                        }
                    }
                    .navigationTitle("Descubrir")
                }
            }
        }
        // Escuchamos el valor publicado por el carrusel (portada centrada)
        .onPreferenceChange(CenteredCoverPreferenceKey.self) { value in
            focusedCoverURL = value
        }
        .onPreferenceChange(CarouselFramePreferenceKey.self) { rect in
            carouselFrame = rect
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
        LazyVStack(alignment: .leading) {
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
        .padding()
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
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical)
    }
}

#Preview {
    PreviewBootstrap { HomeView() }
        .previewModelContainer()
}
