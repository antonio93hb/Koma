//
//  MangaDetailView.swift
//  MangApp
//
//  Created by Antonio Hernández Barbadilla on 13/6/25.
//

import SwiftUI

struct MangaDetailView: View {
    
    let manga: Manga
    
    var body: some View {
        Text("\(manga.title) detail")
    }
}

#Preview {
    MangaDetailView(manga: .test)
}
