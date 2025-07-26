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
    let imageURL: String?

    var body: some View {
        NavigationView {
            ZStack{
                if let imageURL = imageURL {
                    BlurredBackground(imageURL: imageURL)
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let english = titleEnglish, !english.isEmpty {
                            section(title: "Título en Inglés") {
                                Text(english).font(.body)
                            }
                        }
                        if let japanese = titleJapanese, !japanese.isEmpty {
                            section(title: "Título en Japonés") {
                                Text(japanese).font(.body)
                            }
                        }
                        if !authors.isEmpty {
                            section(title: "Autores") {
                                ForEach(authors, id: \.id) { author in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(author.fullName).font(.headline)
                                        Text(author.role).font(.subheadline).foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        if !demographics.isEmpty {
                            section(title: "Demografía") {
                                ForEach(demographics, id: \.id) { demo in
                                    Text(demo.name)
                                }
                            }
                        }
                        if !genres.isEmpty {
                            section(title: "Géneros") {
                                ForEach(genres, id: \.id) { genre in
                                    Text(genre.genre)
                                }
                            }
                        }
                        if let background, !background.isEmpty {
                            section(title: "Información adicional") {
                                Text(background)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                    .padding(.vertical, 4)
                            }
                        }
                        if let urlString = url, !urlString.isEmpty, let validURL = URL(string: urlString) {
                            section(title: "URL") {
                                Link(urlString, destination: validURL)
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                                    .lineLimit(1)
                            }
                        }
                        if !themes.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Temas")
                                    .font(.headline)
                                    .padding(.horizontal)
                                FlowLayout(items: themes.map { $0.name }) { themeName in
                                    let style = ThemeUIHelper.style(for: themeName)
                                    Label(style.name, systemImage: style.icon)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(style.color.opacity(0.15))
                                        )
                                        .foregroundColor(style.color)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Información")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline).padding(.bottom, 2)
            content()
        }
        .padding(.horizontal)
    }
}

struct FlowLayout<Content: View>: View {
    let items: [String]
    let content: (String) -> Content

    init(items: [String], @ViewBuilder content: @escaping (String) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    content(item)
                }
            }
            .padding(.horizontal)
        }
    }
}
