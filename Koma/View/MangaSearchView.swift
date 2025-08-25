//
//  MangaSearchView.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 27/7/25.
//

import SwiftUI

struct MangaSearchView: View {
    @State private var isExpanded: Bool = false
    @Environment(SearchViewModel.self) var searchViewModel
    @Environment(MangaViewModel.self) var mangaViewModel
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    // Capa base
                    Color(.systemBackground)
                        .ignoresSafeArea()

                    // Fondo borroso adaptado a altura de pantalla
                    if let bgURL = searchViewModel.currentBGURL {
                        BlurredBackground(
                            imageURL: bgURL,
                            blur: 24,
                            opacity: 0.18,
                            height: geo.size.height * 0.45,
                            fadeDistance: 120 + 16,
                            showTopShadow: false
                        )
                        .allowsHitTesting(false)
                        .ignoresSafeArea(edges: .top)
                        .zIndex(0)
                    }

                    // --- CONTENIDO ---
                    VStack {
                        searchBar
                        filtersSection
                        if searchViewModel.isLoading {
                            loadingSection
                        } else {
                            if searchViewModel.shouldShowHistory {
                                Text("Historial de búsquedas")
                                    .font(.headline)
                                    .padding(.horizontal)
                            } else if searchViewModel.shouldShowResults {
                                Text("Resultados:")
                                    .font(.headline)
                                    .padding(.horizontal)
                            }

                            ScrollView {
                                Group {
                                    if searchViewModel.shouldShowHistory {
                                        historySection
                                    } else if searchViewModel.shouldShowNoResults {
                                        noResultsSection
                                    } else if searchViewModel.shouldShowResults {
                                        resultsSection
                                    }
                                }
                            }
                            .scrollDismissesKeyboard(.interactively)
                        }
                    }
                    .zIndex(1)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isSearchFocused = false
            }
            .navigationTitle("Buscar")
            .navigationBarTitleDisplayMode(isSearchFocused ? .inline : .automatic)
            .toolbarBackground(isSearchFocused ? .visible : .hidden, for: .navigationBar)
            .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
            .onAppear {
                searchViewModel.computeFallbackBackground(
                    allMangas: mangaViewModel.mangas,
                    savedMangas: mangaViewModel.savedMangas
                )
            }
        }
    }
    
    @ViewBuilder
    private var searchBar: some View {
        // Barra de búsqueda y botón
        HStack {
            TextField("Buscar manga...", text: Binding(
                get: { searchViewModel.searchTitle },
                set: { searchViewModel.searchTitle = $0 }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($isSearchFocused)
            .onSubmit {
                Task { await searchViewModel.searchIfNeeded() }
                isSearchFocused = false
            }
            Button(action: {
                Task { await searchViewModel.searchIfNeeded() }
                isSearchFocused = false
            }) {
                Image(systemName: "magnifyingglass")
                    .imageScale(.large)
                    .padding(.leading, 8)
            }
            if isSearchFocused || !searchViewModel.searchTitle.isEmpty || searchViewModel.hasSearched {
                Button(action: {
                    searchViewModel.clearSearch()
                    isSearchFocused = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .padding(.leading, 8)
                }
            }
        }
        .padding()
        
        // Mensaje de error
        if let error = searchViewModel.errorMessage {
            Text(error)
                .foregroundColor(.red)
                .padding()
        }
    }
    
    @ViewBuilder
    private var filtersSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                Text("Filtros")
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .font(.headline)
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primary.opacity(0.1))
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemBackground)))
            )
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                HStack {
                    FilterMenu(
                        title: "Género",
                        items: GenreUIHelper.allGenres,
                        selectedItems: Binding(
                            get: { searchViewModel.selectedGenres },
                            set: { newValue in
                                searchViewModel.selectedGenres = newValue
                            }
                        ),
                        styleProvider: { GenreUIHelper.style(for: $0) }
                    )
                    
                    FilterMenu(
                        title: "Temas",
                        items: ThemeUIHelper.allThemes,
                        selectedItems: Binding(
                            get: { searchViewModel.selectedThemes },
                            set: { newValue in
                                searchViewModel.selectedThemes = newValue
                            }
                        ),
                        styleProvider: { ThemeUIHelper.style(for: $0) }
                    )
                    
                    FilterMenu(
                        title: "Demografía",
                        items: DemographicUIHelper.allDemographics,
                        selectedItems: Binding(
                            get: { searchViewModel.selectedDemographics },
                            set: { newValue in
                                searchViewModel.selectedDemographics = newValue
                            }
                        ),
                        styleProvider: { DemographicUIHelper.style(for: $0) }
                    )
                }
                .padding()
                .transition(.opacity.combined(with: .slide))
                
                // Mostrar etiquetas seleccionadas agrupadas por categoría
                FilterTagSection(
                    title: "Género",
                    items: Binding(
                        get: { searchViewModel.selectedGenres },
                        set: { newValue in
                            searchViewModel.selectedGenres = newValue
                        }
                    ),
                    styleProvider: { GenreUIHelper.style(for: $0) }
                )
                
                FilterTagSection(
                    title: "Temas",
                    items: Binding(
                        get: { searchViewModel.selectedThemes },
                        set: { newValue in
                            searchViewModel.selectedThemes = newValue
                        }
                    ),
                    styleProvider: { ThemeUIHelper.style(for: $0) }
                )
                
                FilterTagSection(
                    title: "Demografía",
                    items: Binding(
                        get: { searchViewModel.selectedDemographics },
                        set: { newValue in
                            searchViewModel.selectedDemographics = newValue
                        }
                    ),
                    styleProvider: { DemographicUIHelper.style(for: $0) }
                )
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var historySection: some View {
        VStack(spacing: 0) {
            ForEach(searchViewModel.searchHistory, id: \.id) { search in
                VStack(spacing: 0) {
                    SearchHistoryRow(
                        history: search,
                        onDelete: {
                            Task { await searchViewModel.deleteSearchHistory(search) }
                        },
                        onSelect: {
                            Task { await searchViewModel.performSearch(from: search) }
                        }
                    )
                    Divider()
                        .background(Color.secondary.opacity(0.3))
                        .padding(.leading)
                }
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var resultsSection: some View {
        if !searchViewModel.searchResults.isEmpty {
            LazyVStack {
                ForEach(searchViewModel.searchResults, id: \.id) { manga in
                    NavigationLink(destination: MangaDetailView(manga: manga)) {
                        MangaRow(manga: manga)
                            .onAppear {
                                if manga.id == searchViewModel.searchResults.last?.id {
                                    Task { await searchViewModel.loadMoreIfNeeded(current: manga) }
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var loadingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.2)
            Text("Buscando…")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
    
    @ViewBuilder
    private var noResultsSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.secondary.opacity(0.6))

            Text("No se han encontrado resultados")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .padding()
    }
}
#Preview {
    PreviewBootstrap { MangaSearchView() }
        .previewModelContainer()
}
