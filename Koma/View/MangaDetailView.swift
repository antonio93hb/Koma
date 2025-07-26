//
//  MangaDetailView.swift
//  MangApp
//
//  Created by Antonio Hernández Barbadilla on 13/6/25.
//

import SwiftUI
import SwiftData

// MARK: - MangaDetailView
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
            BlurredBackground(imageURL: manga.imageURL)

            ScrollView {
                VStack(spacing: 24) {

                    // Imagen, título y estado (centrados)
                    MangaHeaderView(manga: manga)

                    // Sinopsis
                    if let synopsis = manga.synopsis {
                        SynopsisView(synopsis: synopsis)
                    }

                    // Fecha, capítulos, tomos, progreso y puntuación encapsulados
                    InfoSectionView(manga: manga, ownedVolumes: ownedVolumes)

                    // Botón "Añadir" o gestión de guardado y botón de más info alineados horizontalmente
                    HStack {
                        SaveButtonsView(
                            manga: manga,
                            mangaIsAlreadySaved: $mangaIsAlreadySaved,
                            ownedVolumes: $ownedVolumes,
                            ownedVolumesInput: $ownedVolumesInput,
                            showAlert: $showAlert,
                            activeAlert: $activeAlert,
                            showMoreInfoSheet: $showMoreInfoSheet,
                            viewModel: viewModel
                        )
                    }
                    .frame(maxWidth: 350)
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
                    demographics: manga.demographics,
                    background: manga.background
                )
            }
        }
        .onAppear {
            Task {
                mangaIsAlreadySaved = try await viewModel.isMangaSaved(manga.id)
                ownedVolumes = await viewModel.getOwnedVolumes(for: manga.id)
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - MangaHeaderView
    struct MangaHeaderView: View {
        let manga: Manga

        var body: some View {
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
        }
    }
    // MARK: - SynopsisView
    @ViewBuilder
    private func SynopsisView(synopsis: String) -> some View {
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
}

extension MangaDetailView {
    // MARK: - InfoSectionView
    private struct InfoSectionView: View {
        let manga: Manga
        let ownedVolumes: Int?
        @Environment(\.colorScheme) private var colorScheme
        
        var body: some View {
            VStack(spacing: 4) {
                if let start = manga.startDate {
                    if let end = manga.endDate {
                        Label("Finalizado el \(end.formatted(date: .long, time: .omitted))", systemImage: "calendar")
                            .foregroundColor(.red)
                    } else {
                        Label("En emisión desde \(start.formatted(date: .long, time: .omitted))", systemImage: "calendar")
                            .foregroundColor(.green)
                    }
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
                    VStack(spacing: 4) {
                        ProgressView(value: Float(owned), total: Float(total))
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .frame(maxWidth: 200)
                        Text("Tomos: \(owned) / \(total)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    if owned == total {
                        Label("¡Colección completa!", systemImage: "checkmark.seal")
                            .foregroundColor(.green)
                    }
                }
                
                if let score = manga.score {
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            let roundedScore = (score * 2).rounded() / 2
                            let fullStars = Int(floor(roundedScore))
                            let hasHalfStar = roundedScore - Double(fullStars) == 0.5
                            let borderColor = colorScheme == .dark ? Color.white : Color.black

                            ForEach(1...10, id: \.self) { index in
                                if index <= fullStars {
                                    Image(systemName: "star.fill")
                                        .font(.title3)
                                        .foregroundColor(.yellow)
                                        .overlay(
                                            Image(systemName: "star")
                                                .font(.title3)
                                                .foregroundColor(borderColor)
                                        )
                                } else if index == fullStars + 1 && hasHalfStar {
                                    Image(systemName: "star.leadinghalf.filled")
                                        .font(.title3)
                                        .foregroundColor(.yellow)
                                        .overlay(
                                            Image(systemName: "star")
                                                .font(.title3)
                                                .foregroundColor(borderColor)
                                        )
                                } else {
                                    Image(systemName: "star")
                                        .font(.title3)
                                        .foregroundColor(borderColor)
                                }
                            }
                        }
                        Text("\(score, specifier: "%.1f")/10")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .font(.subheadline)
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    // MARK: - SaveButtonsView
    private struct SaveButtonsView: View {
        let manga: Manga
        @Binding var mangaIsAlreadySaved: Bool
        @Binding var ownedVolumes: Int?
        @Binding var ownedVolumesInput: String
        @Binding var showAlert: Bool
        @Binding var activeAlert: AppAlert?
        @Binding var showMoreInfoSheet: Bool
        let viewModel: MangaViewModel
        
        var body: some View {
            if mangaIsAlreadySaved {
                VStack{
                    HStack{
                        Label("Guardado", systemImage: "checkmark")
                            .font(.subheadline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.gray.opacity(0.1))
                            .foregroundColor(.gray)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                            .shadow(radius: 0.5)
                        MoreInfoButtonView(showMoreInfoSheet: $showMoreInfoSheet)
                    }
                    HStack{
                        if manga.volumes != nil {
                            AppGlassButton(title: "Modificar", systemImage: "books.vertical") {
                                showAlert = true
                            }
                            .tint(.blue)
                        }
                        AppGlassButton(title: "Borrar", systemImage: "trash") {
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
                        }
                        .tint(.red)
                    }
                }
            } else {
                HStack{
                    AppGlassButton(title: "Añadir", systemImage: "books.vertical") {
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
                    }
                    MoreInfoButtonView(showMoreInfoSheet: $showMoreInfoSheet)
                }
            }
        }
    }
    
    // MARK: - MoreInfoButtonView
    private struct MoreInfoButtonView: View {
        @Binding var showMoreInfoSheet: Bool

        var body: some View {
            AppGlassButton(title: "Más info", systemImage: "info.circle") {
                showMoreInfoSheet = true
            }
        }
    }
}



// MARK: - Preview
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
