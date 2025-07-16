//
//  CarruselSectionView.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 21/6/25.
//
import SwiftUI

struct CarruselSectionView: View {
    @Environment(MangaViewModel.self) var viewModel
    
    var body: some View {
        Section {
            GeometryReader { geometry in
                ScrollViewReader { scrollProxy in
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
                    .scrollTargetBehavior(.viewAligned)
                    .ignoresSafeArea(edges: [.leading, .trailing])
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .frame(height: 180)
        }
    }
}

#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    var body: some View {
        let testVM = MangaViewModel(network: NetworkTest())
        List {
            CarruselSectionView()
        }
        .environment(testVM)
        .task {
            await testVM.getBestMangas()
        }
    }
}
