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
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            VStack {
                searchBar
                filtersSection
                historySection
                resultsSection
            }
            .navigationTitle("Buscar")
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
            .onSubmit {
                Task { await searchViewModel.searchIfNeeded() }
            }
            Button(action: {
                Task { await searchViewModel.searchIfNeeded() }
            }) {
                Image(systemName: "magnifyingglass")
                    .imageScale(.large)
                    .padding(.leading, 8)
            }
            if !searchViewModel.searchTitle.isEmpty || searchViewModel.hasSearched {
                Button(action: {
                    searchViewModel.clearSearch()
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
                                Task { await searchViewModel.updateFilters(genres: newValue) }
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
                                Task { await searchViewModel.updateFilters(themes: newValue) }
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
                                Task { await searchViewModel.updateFilters(demographics: newValue) }
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
                            Task { await searchViewModel.updateFilters(genres: newValue) }
                        }
                    ),
                    styleProvider: { GenreUIHelper.style(for: $0) }
                )
                
                FilterTagSection(
                    title: "Temas",
                    items: Binding(
                        get: { searchViewModel.selectedThemes },
                        set: { newValue in
                            Task { await searchViewModel.updateFilters(themes: newValue) }
                        }
                    ),
                    styleProvider: { ThemeUIHelper.style(for: $0) }
                )
                
                FilterTagSection(
                    title: "Demografía",
                    items: Binding(
                        get: { searchViewModel.selectedDemographics },
                        set: { newValue in
                            Task { await searchViewModel.updateFilters(demographics: newValue) }
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
        // Historial de búsquedas
        if !searchViewModel.hasSearched {
            VStack(alignment: .leading, spacing: 4) {
                Text("Historial de búsquedas")
                    .font(.headline)
                    .padding(.horizontal)
                ForEach(searchViewModel.searchHistory, id: \.id) { search in
                    SearchHistoryRow(
                        history: search,
                        onDelete: {
                            Task { await searchViewModel.deleteSearchHistory(search) }
                        },
                        onSelect: {
                            Task { await searchViewModel.performSearch(from: search) }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var resultsSection: some View {
        // Resultados usando ScrollView y LazyVStack
        if !searchViewModel.searchResults.isEmpty {
            Text("Resultados: ")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        }
        ScrollView {
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
            }
            .padding()
        }
    }
}
