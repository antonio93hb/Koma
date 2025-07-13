//
//  CarruselSectionView.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 21/6/25.
//
import SwiftUI

struct CarruselSectionView: View {
//    let viewModel: MangaListViewModel
    @Environment(MangaViewModel.self) var viewModel
    
    var body: some View {
        Section {
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack (spacing: 40){
                        ForEach(viewModel.bestMangas) { manga in
                            NavigationLink(
                                destination: MangaDetailView(manga: manga)
                            ) {
                                MangaCardCarrusel(manga: manga)
                                    .frame(width: 280)
                                    .id(manga.id)
                            }
                        }
                    }
                    .frame(height: 250)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                
                .onAppear {
                    Task {
                        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 segundos
                        if viewModel.bestMangas.count > 1 && viewModel.mangas.count > 1 {
                            withAnimation {
                                scrollProxy.scrollTo(viewModel.mangas[1].id, anchor: .center)
                            }
                        }
                    }
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }
}

//#Preview {
//    let vm = MangaListViewModel(network: NetworkTest())
//    Task {
//        await vm.getBestMangas()
//    }
//    List {
//        CarruselSectionView(viewModel: vm)
//    }
//}
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
