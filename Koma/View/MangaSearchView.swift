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

    var body: some View {
        NavigationStack {
            VStack {
                // Barra de búsqueda y botón
                HStack {
                    TextField("Buscar manga...", text: Binding(
                        get: { searchViewModel.searchTitle },
                        set: { searchViewModel.searchTitle = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        Task { await searchViewModel.performSearch() }
                    }
                    Button(action: {
                        Task {
                            await searchViewModel.performSearch()
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .imageScale(.large)
                            .padding(.leading, 8)
                    }
                }
                .padding()
                   
                // Indicador de carga
                if searchViewModel.isLoading {
                    ProgressView("Buscando...")
                        .padding()
                }
                
                // Mensaje de error
                if let error = searchViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
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
                        HStack(spacing: 12) {
                            FilterMenu(
                                title: "Género",
                                items: GenreUIHelper.allGenres,
                                selectedItems: Binding(
                                    get: { searchViewModel.selectedGenres },
                                    set: { searchViewModel.selectedGenres = $0 }
                                ),
                                styleProvider: { GenreUIHelper.style(for: $0) }
                            )

                            FilterMenu(
                                title: "Temas",
                                items: ThemeUIHelper.allThemes,
                                selectedItems: Binding(
                                    get: { searchViewModel.selectedThemes },
                                    set: { searchViewModel.selectedThemes = $0 }
                                ),
                                styleProvider: { ThemeUIHelper.style(for: $0) }
                            )

                            FilterMenu(
                                title: "Demografía",
                                items: DemographicUIHelper.allDemographics,
                                selectedItems: Binding(
                                    get: { searchViewModel.selectedDemographics },
                                    set: { searchViewModel.selectedDemographics = $0 }
                                ),
                                styleProvider: { DemographicUIHelper.style(for: $0) }
                            )
                        }
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .slide))
                    }
                }
                .padding()
            
                   if searchViewModel.searchResults.isEmpty && !searchViewModel.isLoading && searchViewModel.hasSearched {
                       VStack(spacing: 8) {
                           Image(systemName: "questionmark.circle")
                               .resizable()
                               .scaledToFit()
                               .frame(width: 40, height: 40)
                               .foregroundColor(.secondary.opacity(0.6))
                           
                           Text("No se han encontrado resultados")
                               .foregroundColor(.secondary)
                               .font(.subheadline)
                       }
                       .padding()
                       .frame(maxWidth: .infinity, alignment: .center)
                   }
                   
                   // Resultados usando ScrollView y LazyVStack
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
               .navigationTitle("Buscar")
           }
       }
}
