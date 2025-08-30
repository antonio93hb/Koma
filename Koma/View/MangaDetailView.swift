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
    let manga: Manga
    @State private var showFullSynopsis = false
    @State private var mangaIsAlreadySaved = false
    @State private var ownedVolumes: Int? = nil
    @State private var readVolumes: Int? = nil
    @State private var activeAlert: AppAlert?
    @State private var showMoreInfoSheet = false

    var body: some View {
        ZStack {
            // 📸 Fondo desenfocado
            Color.clear
                .background {
                    BlurredBackground(imageURL: manga.imageURL)
                }
                .ignoresSafeArea()
                .zIndex(-1)

            ScrollView {
                VStack(spacing: 24) {

                    // Imagen, título y estado (centrados)
                    MangaHeaderView(manga: manga)

                    // Sinopsis
                    if let synopsis = manga.synopsis {
                        SynopsisView(synopsis: synopsis)
                    }

                    // Fecha, capítulos, tomos, progreso y puntuación encapsulados
                    InfoSectionView(manga: manga, ownedVolumes: ownedVolumes, readVolumes: readVolumes)

                    // Botón "Añadir" o gestión de guardado y botón de más info alineados horizontalmente
                    HStack {
                        SaveButtonsView(
                            manga: manga,
                            mangaIsAlreadySaved: $mangaIsAlreadySaved,
                            ownedVolumes: $ownedVolumes,
                            activeAlert: $activeAlert,
                            showMoreInfoSheet: $showMoreInfoSheet,
                            readVolumes: $readVolumes,
                            viewModel: viewModel
                        )
                    }
                    .frame(maxWidth: 350)
                }
            }
            .sheet(isPresented: $showMoreInfoSheet) {
                MoreInfoSheetView(
                    title: manga.title,
                    authors: manga.authors,
                    genres: manga.genres,
                    themes: manga.themes,
                    demographics: manga.demographics,
                    background: manga.background,
                    titleEnglish: manga.titleEnglish,
                    titleJapanese: manga.titleJapanese,
                    url: manga.url,
                    imageURL: manga.imageURL
                )
            }
        }
        .onAppear {
            Task {
                let state = await viewModel.loadMangaState(manga)
                mangaIsAlreadySaved = state.isSaved
                ownedVolumes = state.ownedVolumes
                readVolumes = state.readVolumes
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showMoreInfoSheet = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
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

                Text(manga.mangaStatus.text)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            .background(
                                Capsule()
                                    .fill(Color.gray.opacity(0.05))
                            )
                    )
                    .foregroundColor(.secondary)
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
                Button(showFullSynopsis ? "show_less" : "show_more") {
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
        let readVolumes: Int?

        @Environment(\.colorScheme) private var colorScheme
        
        var body: some View {
            // Define adaptive colors for progress bars
            let savedColor = colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray.opacity(0.4)
            let readColor = colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.5)
            VStack(spacing: 4) {
                if let start = manga.startDate {
                    if let end = manga.endDate {
                        Label(
                            String(
                                format: NSLocalizedString("finished_on_label", comment: ""),
                                end.formatted(date: .long, time: .omitted)
                            ),
                            systemImage: "calendar"
                        )
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.1))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                            .foregroundColor(.secondary)
                    } else {
                        Label(
                            String(
                                format: NSLocalizedString("airing_since_label", comment: ""),
                                start.formatted(date: .long, time: .omitted)
                            ),
                            systemImage: "calendar"
                        )
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.green.opacity(0.1))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                            .foregroundColor(.secondary)
                    }
                }

                HStack(spacing: 16) {
                    if let chapters = manga.chapters {
                        Label("chapters_label \(chapters)", systemImage: "doc.plaintext")
                    }
                    if let volumes = manga.volumes {
                        Label("tomos_label \(volumes)", systemImage: "books.vertical")
                    }
                }

                // Sección de progreso de tomos guardados y leídos
                if let owned = ownedVolumes, let total = manga.volumes {
                    VStack(spacing: 6) {
                        // Barra para tomos guardados
                        ProgressView(value: Float(owned), total: Float(total))
                            .progressViewStyle(LinearProgressViewStyle(tint: savedColor))
                            .frame(maxWidth: 200)
                        Text("owned_volumes_progress \(owned) \(total)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        // Barra para tomos leídos si existe readVolumes
                        if let read = readVolumes {
                            ProgressView(value: Float(read), total: Float(total))
                                .progressViewStyle(LinearProgressViewStyle(tint: readColor))
                                .frame(maxWidth: 200)
                            Text("read_volumes_progress \(read) \(total)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    if let read = readVolumes, read == total {
                        Label("collection_read", systemImage: "checkmark.seal")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.green.opacity(0.1))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                            .foregroundColor(.secondary)
                    } else if owned == total {
                        Label("collection_saved", systemImage: "checkmark.seal")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.1))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                            .foregroundColor(.secondary)
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
                        Text(verbatim: String(format: "%.1f/10", score))                            .font(.caption)
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
    
    // MARK: - VolumeStepperView
    private struct VolumeStepperView: View {
        @Binding var ownedVolumes: Int?
        @Binding var activeAlert: AppAlert?
        let maxVolumes: Int?
        let manga: Manga
        let viewModel: MangaViewModel

        var body: some View {
            // 1. Determina estado de los botones
            let current = ownedVolumes ?? 0
            let isMinusDisabled = current <= 0
            let isPlusDisabled = maxVolumes != nil ? current >= (maxVolumes ?? Int.max) : false

            HStack(spacing: 8) {
                Button(action: {
                    Task {
                        let success = await viewModel.decreaseOwnedVolumes(for: manga)
                        if success {
                            ownedVolumes = max((ownedVolumes ?? 0) - 1, 0)
                        }
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(isMinusDisabled ? .gray : .blue)
                }

                Text(verbatim: "\(ownedVolumes ?? 0)")
                    .font(.headline)
                    .frame(minWidth: 30)

                Button(action: {
                    Task {
                        let success = await viewModel.increaseOwnedVolumes(for: manga)
                        if success {
                            ownedVolumes = min((ownedVolumes ?? 0) + 1, maxVolumes ?? Int.max)
                        }
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(isPlusDisabled ? .gray : .blue)
                }
            }
            .padding(8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.blue.opacity(0.3), lineWidth: 1))
            .shadow(radius: 1)
        }
    }

    // MARK: - SavedStateButtonsView
    private struct SavedStateButtonsView: View {
        let manga: Manga
        @Binding var ownedVolumes: Int?
        @Binding var activeAlert: AppAlert?
        @Binding var showMoreInfoSheet: Bool
        @Binding var mangaIsAlreadySaved: Bool
        @Binding var readVolumes: Int?
        let viewModel: MangaViewModel

        var body: some View {
            VStack {
                // Primer HStack: Guardado, Borrar
                HStack {
                    Label("saved_title", systemImage: "checkmark")
                        .font(.subheadline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.gray.opacity(0.1))
                        .foregroundColor(.gray)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.gray.opacity(0.4), lineWidth: 1))
                        .shadow(radius: 0.5)
                    AppGlassButton(titleKey: "delete", systemImage: "trash") {
                        Task {
                            activeAlert = await viewModel.deleteMangaAndGetAlert(manga)
                            if activeAlert == .deleted {
                                mangaIsAlreadySaved = false
                                ownedVolumes = nil
                            }
                        }
                    }
                    .tint(.red)
                }
                // Segundo HStack: OwnedVolumesMenu y ReadVolumeStepperView en la misma línea
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .center, spacing: 4) {
                        Text("owned_label")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if manga.volumes != nil {
                            OwnedVolumesMenu(
                                ownedVolumes: $ownedVolumes,
                                readVolumes: $readVolumes,
                                maxVolumes: manga.volumes,
                                manga: manga,
                                viewModel: viewModel
                            )
                        }
                    }
                    VStack(alignment: .center, spacing: 4) {
                        Text("read_label")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let owned = ownedVolumes, owned > 0 {
                            ReadVolumeStepperView(
                                readVolumes: $readVolumes,
                                maxVolumes: ownedVolumes,
                                manga: manga,
                                viewModel: viewModel
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - UnsavedStateButtonsView
    private struct UnsavedStateButtonsView: View {
        let manga: Manga
        @Binding var mangaIsAlreadySaved: Bool
        @Binding var activeAlert: AppAlert?
        @Binding var showMoreInfoSheet: Bool
        let viewModel: MangaViewModel

        var body: some View {
            HStack {
                AppGlassButton(titleKey: "add", systemImage: "books.vertical") {
                    Task {
                        activeAlert = await viewModel.saveMangaAndGetAlert(manga)
                        mangaIsAlreadySaved = (activeAlert == .saved)
                    }
                }
            }
        }
    }

    // MARK: - SaveButtonsView
    private struct SaveButtonsView: View {
        let manga: Manga
        @Binding var mangaIsAlreadySaved: Bool
        @Binding var ownedVolumes: Int?
        @Binding var activeAlert: AppAlert?
        @Binding var showMoreInfoSheet: Bool
        @Binding var readVolumes: Int?
        let viewModel: MangaViewModel

        var body: some View {
            if mangaIsAlreadySaved {
                SavedStateButtonsView(
                    manga: manga,
                    ownedVolumes: $ownedVolumes,
                    activeAlert: $activeAlert,
                    showMoreInfoSheet: $showMoreInfoSheet,
                    mangaIsAlreadySaved: $mangaIsAlreadySaved,
                    readVolumes: $readVolumes,
                    viewModel: viewModel
                )
            } else {
                UnsavedStateButtonsView(
                    manga: manga,
                    mangaIsAlreadySaved: $mangaIsAlreadySaved,
                    activeAlert: $activeAlert,
                    showMoreInfoSheet: $showMoreInfoSheet,
                    viewModel: viewModel
                )
            }
        }
    }
    
    // MARK: - ReadVolumeStepperView
    private struct ReadVolumeStepperView: View {
        @Binding var readVolumes: Int?
        let maxVolumes: Int?
        let manga: Manga
        let viewModel: MangaViewModel

        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            let current = readVolumes ?? 0
            let isMinusDisabled = current <= 0
            let isPlusDisabled = maxVolumes != nil ? current >= (maxVolumes ?? 0) : false

            let activeColor = colorScheme == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.6)
            let disabledColor = colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray.opacity(0.3)

            HStack(spacing: 8) {
                Button {
                    Task {
                        let success = await viewModel.decreaseReadVolumes(for: manga)
                        if success { readVolumes = max(current - 1, 0) }
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(isMinusDisabled ? disabledColor : activeColor)
                }

                Text(verbatim: "\(current)")
                    .font(.headline)
                    .frame(minWidth: 30)

                Button {
                    Task {
                        let success = await viewModel.increaseReadVolumes(for: manga)
                        if success { readVolumes = min(current + 1, maxVolumes ?? Int.max) }
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(isPlusDisabled ? disabledColor : activeColor)
                }
            }
            .padding(8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .shadow(radius: 1)
        }
    }
}

// MARK: - OwnedVolumesMenu
private struct OwnedVolumesMenu: View {
    @Binding var ownedVolumes: Int?
    @Binding var readVolumes: Int?
    let maxVolumes: Int?
    let manga: Manga
    let viewModel: MangaViewModel

    var body: some View {
        Menu {
            if let total = maxVolumes, total > 0 {
                ForEach(1...total, id: \.self) { tomo in
                    Button("volume_label \(tomo)") {
                        Task {
                            let success = await viewModel.updateOwnedVolumes(for: manga, to: tomo)
                            if success {
                                ownedVolumes = tomo
                                readVolumes = min(readVolumes ?? 0, tomo)
                            }
                        }
                    }
                }
            }
        } label: {
            Label("volumes_label: \(ownedVolumes ?? 0)", systemImage: "books.vertical")
                .padding(8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .shadow(radius: 1)
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
