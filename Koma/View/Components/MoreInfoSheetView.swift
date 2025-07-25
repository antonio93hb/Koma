//
//  AuthorsSheetView.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 25/7/25.
//

import SwiftUI

struct MoreInfoSheetView: View {
    let authors: [Author]
    let genres: [Genre]
    let themes: [Theme]
    let demographics: [Demographic]

    var body: some View {
        NavigationView {
            List {
                if !authors.isEmpty {
                    Section(header: Text("Autores")) {
                        ForEach(authors, id: \.id) { author in
                            VStack(alignment: .leading) {
                                Text(author.fullName)
                                    .font(.headline)
                                Text(author.role)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                if !demographics.isEmpty {
                    Section(header: Text("Demografía")) {
                        ForEach(demographics, id: \.id) { demographic in
                            Text(demographic.name)
                        }
                    }
                }

                if !genres.isEmpty {
                    Section(header: Text("Géneros")) {
                        ForEach(genres, id: \.id) { genre in
                            Text(genre.genre)
                        }
                    }
                }

                if !themes.isEmpty {
                    Section(header: Text("Temas")) {
                        ForEach(themes, id: \.id) { theme in
                            Text(theme.name)
                        }
                    }
                }
            }
            .navigationTitle("Información")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FlowLayout: View {
    let items: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
    }
}
