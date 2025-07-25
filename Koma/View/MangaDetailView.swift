//
//  MangaDetailView.swift
//  MangApp
//
//  Created by Antonio Hernández Barbadilla on 13/6/25.
//

import SwiftUI
import SwiftData

struct MangaDetailView: View {

    @Environment(MangaViewModel.self) var viewModel
    @Environment(\.modelContext) private var context
    let manga: Manga
    @State private var showFullSynopsis = false
    @State private var mangaIsAlreadySaved = false
    @State private var showAlert = false
    @State private var ownedVolumesInput = ""
    @State private var ownedVolumes: Int? = nil
    @State private var activeAlert: AppAlert?
    @State private var showMoreInfoSheet = false

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
                            .opacity(0.3)
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
                            .lineLimit(nil)
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.9)

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

                    // Fecha, capítulos y tomos con iconos
                    VStack(spacing: 4) {
                        if let startDate = manga.startDate {
                            Label(startDate.formatted(date: .complete, time: .omitted), systemImage: "calendar")
                        }
                        HStack(spacing: 16) {
                            if let chapters = manga.chapters {
                                Label("Capítulos: \(chapters)", systemImage: "doc.plaintext")
                            }
                            if let volumes = manga.volumes {
                                Label("Tomos: \(volumes)", systemImage: "books.vertical")
                            }
                        }
                        if let owned = ownedVolumes, let total = manga.volumes {
                            Label("Colección: \(owned) / \(total)", systemImage: "archivebox")
                            if owned == total {
                                Label("¡Colección completa!", systemImage: "checkmark.seal")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)

                    // Botón "Añadir" o gestión de guardado
                    if mangaIsAlreadySaved {
                        HStack(spacing: 12) {
                            Label("Guardado", systemImage: "checkmark")
                                .padding()
                                .frame(maxWidth: 200)
                                .background(.gray.opacity(0.2))
                                .foregroundColor(.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            if manga.volumes != nil {
                                Button {
                                    showAlert = true
                                } label: {
                                    Image(systemName: "books.vertical")
                                        .padding()
                                        .frame(width: 48, height: 48)
                                        .background(.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }

                            Button {
                                Task {
                                    do {
                                        try await viewModel.unSaveManga(manga)
                                        mangaIsAlreadySaved = false
                                        ownedVolumes = nil
                                        activeAlert = .deleted
                                        await viewModel.refreshSavedMangas()
                                    } catch {
                                        activeAlert = .failedToDelete
                                    }
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .padding()
                                    .frame(width: 48, height: 48)
                                    .background(.red.opacity(0.2))
                                    .foregroundColor(.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Button {
                            Task {
                                do {
                                    try await viewModel.saveManga(manga)
                                    await viewModel.refreshSavedMangas()
                                    mangaIsAlreadySaved = true
                                    activeAlert = .saved
                                } catch {
                                    activeAlert = .failedToSave
                                }
                            }
                        } label: {
                            Label("Añadir", systemImage: "books.vertical")
                                .padding()
                                .frame(maxWidth: 300)
                                .background(.white)
                                .foregroundColor(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }

                    // Botones inferiores
                    Button {
                        showMoreInfoSheet = true
                    } label: {
                        Label("Más info", systemImage: "info.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .alert("Modificar tomos", isPresented: $showAlert, actions: {
                    TextField("Número de tomos", text: $ownedVolumesInput)
                        .keyboardType(.numberPad)
                    Button("Guardar") {
                        if let total = manga.volumes {
                            Task {
                                let success = await viewModel.handleOwnedVolumeUpdate(for: manga.id, input: ownedVolumesInput, max: total)
                                if success {
                                    ownedVolumes = Int(ownedVolumesInput)
                                    activeAlert = .successVolumes
                                    await viewModel.refreshSavedMangas()
                                } else {
                                    activeAlert = .invalidInput
                                }
                            }
                        } else {
                            activeAlert = .invalidInput
                        }
                    }
                    Button("Cancelar", role: .cancel) { }
                })
                .alert(item: $activeAlert) { $0.alert }
            }
            .sheet(isPresented: $showMoreInfoSheet) {
                MoreInfoSheetView(
                    authors: manga.authors,
                    genres: manga.genres,
                    themes: manga.themes,
                    demographics: manga.demographics
                )
            }
        }
        .onAppear {
            Task {
                mangaIsAlreadySaved = try await viewModel.isMangaSaved(manga.id)
                ownedVolumes = await viewModel.getOwnedVolumes(for: manga.id)
            }
        }
    }
}

#Preview {
    let mockViewModel = MangaViewModel()
    return MangaDetailPreviewWrapper(manga: .test)
        .environment(mockViewModel)
}

private struct MangaDetailPreviewWrapper: View {
    let manga: Manga

    var body: some View {
        MangaDetailView(manga: manga)
            .modelContainer(for: MangaDB.self, inMemory: true)
    }
}
