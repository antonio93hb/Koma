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
           NavigationView {
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
                   
                   // Resultados usando MangaRow
                   List(searchViewModel.searchResults, id: \.id) { manga in
                       MangaRow(manga: manga)
                   }
               }
               .navigationTitle("Buscar")
           }
       }
}
