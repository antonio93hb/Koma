//
//  MangaDetailView.swift
//  MangApp
//
//  Created by Antonio Hernández Barbadilla on 13/6/25.
//
import SwiftUI

struct MangaDetailView: View {

    let manga: Manga
    @State private var showFullSynopsis = false

    var body: some View {
        ZStack {
            // 📸 Fondo desenfocado
            if let url = URL(string: manga.imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .blur(radius: 40)
                            .opacity(0.2)
                            .ignoresSafeArea()
                    default:
                        EmptyView()
                    }
                }
            }

            ScrollView {
                VStack(spacing: 24) {

                    // Imagen, título y estado (centrados)
                    VStack(spacing: 12) {
                        MangaImg(manga: manga)
                            .frame(width: 200, height: 300)
                            .shadow(radius: 8)

                        Text(manga.title)
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.center)

                        Text(manga.status)
                            .font(.headline)
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    // Sinopsis
                    if let synopsis = manga.synopsis {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(showFullSynopsis ? synopsis : String(synopsis.prefix(150)) + "...")
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .frame(maxWidth: UIScreen.main.bounds.width * 0.9, alignment: .leading)

                            if synopsis.count > 150 {
                                Button(showFullSynopsis ? "menos" : "más") {
                                    withAnimation {
                                        showFullSynopsis.toggle()
                                    }
                                }
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Fecha y capítulos
                    HStack(spacing: 16) {
                        if let startDate = manga.startDate {
                            Text(startDate.formatted(date: .abbreviated, time: .omitted))
                        }
                        if let chapters = manga.chapters {
                            Text("Capítulos: \(chapters)")
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)

                    // Botón "Añadir"
                    Button {
                        // Acción guardar
                    } label: {
                        Label("Añadir", systemImage: "books.vertical")
                            .padding()
                            .frame(maxWidth: 300)
                            .background(.white)
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    // Botones inferiores
                    HStack(spacing: 16) {
                        bottomButton(title: "Autores", systemImage: "person.2")
                        bottomButton(title: "Géneros", systemImage: "square.stack.3d.up")
                        bottomButton(title: "Ver", systemImage: "book")
                    }
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .center)

                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
        }
    }

    private func bottomButton(title: String, systemImage: String) -> some View {
        Button {
            // Acción
        } label: {
            VStack {
                Image(systemName: systemImage)
                Text(title)
            }
            .padding(10)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    MangaDetailView(manga: .test)
}
