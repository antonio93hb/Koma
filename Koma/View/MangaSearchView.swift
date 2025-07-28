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
                   // Barra de búsqueda
                   TextField("Buscar manga...", text: Binding(
                       get: { searchViewModel.searchTitle },
                       set: { searchViewModel.searchTitle = $0 }
                   ))
                   .textFieldStyle(RoundedBorderTextFieldStyle())
                   .padding()
                   .onSubmit {
                       Task { await searchViewModel.performSearch() }
                   }
                   // Botón buscar
                   Button("Buscar") {
                       Task {
                           await searchViewModel.performSearch()
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
