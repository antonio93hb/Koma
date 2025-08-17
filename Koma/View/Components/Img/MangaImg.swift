//
//  MangaImg.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 20/6/25.
//

import SwiftUI

struct MangaImg: View {
    
    @Environment(\.colorScheme) var colorScheme

    let manga: Manga
    
    var body: some View {
        AsyncImage(url: URL(string: manga.imageURL)) { image in
            image.resizable()
        } placeholder: {
            Color.gray
        }
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}
#Preview {
    List {
        MangaImg(manga: .test)
    }
}
