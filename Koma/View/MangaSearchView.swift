//
//  MangaSearchView.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 27/7/25.
//

import SwiftUI

struct MangaSearchView: View {
    @Environment(SearchViewModel.self) private var viewModel
       
       var body: some View {
           NavigationView {
               VStack {
                   // Barra de búsqueda
                   TextField("Buscar manga...", text: Binding(
                       get: { "" },
                       set: { viewModel.searchTitle = $0 }
                   ))
                   .textFieldStyle(RoundedBorderTextFieldStyle())
                   .padding()
                   
                   // Botón buscar
                   Button("Buscar") {
                       Task {
                           await viewModel.testSearch() // ✅ Usamos método de prueba
                       }
                   }
                   .padding()
                   
                   // Indicador de carga
                   if viewModel.isLoading {
                       ProgressView("Buscando...")
                           .padding()
                   }
                   
                   // Mensaje de error
                   if let error = viewModel.errorMessage {
                       Text(error)
                           .foregroundColor(.red)
                           .padding()
                   }
                   
                   // Resultados
                   List(viewModel.searchResults, id: \.id) { manga in
                       Text(manga.title)
                   }
               }
               .navigationTitle("Buscar")
           }
       }
}
