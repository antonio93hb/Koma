//
//  AuthorsSheetView.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 25/7/25.
//

import SwiftUI

struct MoreInfoSheetView: View {
    let title: String
    let authors: [Author]
    let genres: [Genre]
    let themes: [Theme]
    let demographics: [Demographic]
    let background: String?
    let titleEnglish: String?
    let titleJapanese: String?
    let url: String?
    let imageURL: String?
    
    @State private var showAdditionalInfo = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    headerSection()
                    authorsSection()
                    demographicsSection()
                    genresSection()
                    themesSection()
                    additionalInfoSection()
                    urlSection()
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.9, alignment: .leading)
                .padding()
            }
            .background(
                BlurredBackground(imageURL: imageURL)
            )
            .navigationTitle("Información")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Private Subviews

    @ViewBuilder
    private func headerSection() -> some View {
        HStack(alignment: .center, spacing: 12) {
            // 📍 Títulos (a la izquierda)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)

                if let english = titleEnglish, !english.isEmpty {
                    Text(english)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }

                if let japanese = titleJapanese, !japanese.isEmpty {
                    Text(japanese)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.6, alignment: .leading)

            // 📍 Imagen (a la derecha, centrada)
            AsyncImage(url: URL(string: imageURL ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 120, height: 170)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func authorsSection() -> some View {
        if !authors.isEmpty {
            section(title: "Autores") {
                ForEach(authors, id: \.id) { author in
                    HStack(alignment: .center, spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 32, height: 32)
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(author.fullName)
                                .font(.headline)
                                .italic()
                            Text(author.role)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    @ViewBuilder
    private func demographicsSection() -> some View {
        if !demographics.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text("Demografía")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(demographics, id: \.id) { demo in
                            TagLabel(text: demo.name, style: DemographicUIHelper.style(for: demo.name))
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    @ViewBuilder
    private func genresSection() -> some View {
        if !genres.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text("Géneros")
                    .font(.headline)
                    .padding(.horizontal)
                FlowLayout(items: genres.map { $0.genre }) { genreName in
                    TagLabel(text: genreName, style: GenreUIHelper.style(for: genreName))
                }
            }
        }
    }

    @ViewBuilder
    private func themesSection() -> some View {
        if !themes.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text("Temas")
                    .font(.headline)
                    .padding(.horizontal)
                FlowLayout(items: themes.map { $0.name }) { themeName in
                    TagLabel(text: themeName, style: ThemeUIHelper.style(for: themeName))
                }
            }
        }
    }

    @ViewBuilder
    private func additionalInfoSection() -> some View {
        if let background, !background.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Información adicional")
                        .font(.headline)
                    Spacer()
                    Image(systemName: showAdditionalInfo ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .padding(.vertical, 4)
                .onTapGesture {
                    withAnimation {
                        showAdditionalInfo.toggle()
                    }
                }

                if showAdditionalInfo {
                    Text(background)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 4)
                        .transition(.opacity.combined(with: .slide))
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func urlSection() -> some View {
        if let urlString = url, !urlString.isEmpty, let validURL = URL(string: urlString) {
            section(title: "URL") {
                Link(urlString, destination: validURL)
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .lineLimit(1)
            }
        }
    }
    
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
            }
            .padding(.vertical, 4)
            
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

#Preview {
    let test = Manga.test
    MoreInfoSheetView(title: test.title, authors: test.authors, genres: test.genres, themes: test.themes, demographics: test.demographics, background: test.background, titleEnglish: test.titleEnglish, titleJapanese: test.titleJapanese, url: test.url, imageURL: test.imageURL
    )
}
