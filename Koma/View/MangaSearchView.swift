//
//  MangaSearchView.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 27/7/25.
//

import SwiftUI

struct MangaSearchView: View {
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
                   
                   Menu {
                       ForEach(GenreUIHelper.allGenres, id: \.self) { genre in
                           Button {
                               searchViewModel.selectedGenres = [genre]
                               Task { await searchViewModel.performSearch() }
                           } label: {
                               HStack {
                                   TagLabel(text: genre, style: GenreUIHelper.style(for: genre))
                                   if searchViewModel.selectedGenres.last == genre {
                                       Image(systemName: "checkmark")
                                           .foregroundColor(.green)
                                   }
                               }
                           }
                       }
                   } label: {
                       if let selected = searchViewModel.selectedGenres.last {
                           TagLabel(text: selected, style: GenreUIHelper.style(for: selected))
                       } else {
                           AppGlassButton(title: "Género", systemImage: "line.3.horizontal.decrease.circle") { }
                       }
                   }
                   .padding(.vertical, 4)
                   
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
