//
//  CarruselSectionView.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 21/6/25.
//
import SwiftUI

struct CarruselSectionView: View {
    @Environment(MangaViewModel.self) var viewModel
    
    @State private var scrollPosition: Int? = nil
    
    var body: some View {
        Section {
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack (spacing: 20) {
                        ForEach(viewModel.bestMangas) { manga in
                            NavigationLink(
                                destination: MangaDetailView(manga: manga)
                            ) {
                                MangaCardCarrusel(manga: manga)
                                    .frame(width: 260)
                                    .id(manga.id)
                            }
                        }
                    }
                    .padding(.horizontal, (geometry.size.width - 280) / 2)
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $scrollPosition)
                // Publicamos vía PreferenceKey la portada del elemento centrado
                .preference(
                    key: CenteredCoverPreferenceKey.self,
                    value: currentCenteredCoverURL
                )
                .onAppear {
                    if scrollPosition == nil {
                        scrollPosition = viewModel.bestMangas.first?.id
                    }
                }
                .scrollTargetBehavior(.viewAligned)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: CarouselFramePreferenceKey.self,
                                value: proxy.frame(in: .named("SCROLL"))
                            )
                    }
                )
            }
            .frame(height: 180)
        }
    }
    
    /// Devuelve la URL (String) de la portada del manga centrado
    private var currentCenteredCoverURL: String? {
        if let id = scrollPosition,
           let centered = viewModel.bestMangas.first(where: { $0.id == id }) {
            return centered.imageURL
        }
        return viewModel.bestMangas.first?.imageURL
    }
}

#Preview {
    PreviewBootstrap {
        List {
            CarruselSectionView()
        }
    }
    .previewModelContainer()
}
