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
    let background: String?
    let titleEnglish: String?
    let titleJapanese: String?
    let url: String?

    var body: some View {
        NavigationView {
            List {
                if let english = titleEnglish, !english.isEmpty {
                    Section(header: Text("Título en Inglés")) {
                        Text(english)
                            .font(.body)
                    }
                }

                if let japanese = titleJapanese, !japanese.isEmpty {
                    Section(header: Text("Título en Japonés")) {
                        Text(japanese)
                            .font(.body)
                    }
                }
                
                if !authors.isEmpty {
                    Section(header: Text("Autores")) {
                        ForEach(authors, id: \.id) { author in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(author.fullName)
                                    .font(.headline)
                                Text(author.role)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
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

                if let background, !background.isEmpty {
                    Section(header: Text("Información adicional")) {
                        Text(background)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .padding(.vertical, 4)
                    }
                }

                if let urlString = url, !urlString.isEmpty,
                   let validURL = URL(string: urlString) {
                    Section(header: Text("URL")) {
                        Link(urlString, destination: validURL)
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .lineLimit(1)
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
