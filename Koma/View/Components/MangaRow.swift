//
//  MangaRow.swift
//  MangApp
//
//  Created by Antonio Hernández Barbadilla on 13/6/25.
//

import SwiftUI

struct MangaRow: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(MangaViewModel.self) var viewModel
    
    @State private var isSaved = false

    let manga: Manga
    var showSavedIcon = false
    
    var body: some View {
        HStack {
            MangaImg(manga: manga)
                .frame(width: 50, height: 70)
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 1.5)
                )
            VStack(alignment: .leading) {
                
                Text(manga.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                if let english = manga.titleEnglish {
                    Text(english)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if showSavedIcon && isSaved {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
            }
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .onAppear {
                    if showSavedIcon {
                        Task {
                            isSaved = try await viewModel.isMangaSaved(manga.id)
                        }
                    }
                }
    }
}

#Preview {
    List {
        MangaRow(manga: .test)
    }
}
