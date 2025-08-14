//
//  SoftBlurBackdrop.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 13/8/25.
//

import SwiftUI

struct SoftBlurBackdrop: View {
    let imageURL: String?
    var body: some View {
        ZStack {
            // Imagen base (si no hay URL, usa un color neutro)
            if let imageURL,
               let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img
                            .resizable()
                            .scaledToFill()
                    default:
                        Color.clear
                    }
                }
            } else {
                Color.clear
            }

            // Capa de material para “matar” los bordes de la imagen
            Rectangle().fill(.ultraThinMaterial).opacity(0.55)
        }
        .blur(radius: 24, opaque: true)          // blur más suave y amplio
        .saturation(1.1)
        .mask(                                   // desvanecer arriba/abajo
            LinearGradient(
                stops: [
                    .init(color: .clear,  location: 0.00),
                    .init(color: .black,  location: 0.18),
                    .init(color: .black,  location: 0.82),
                    .init(color: .clear,  location: 1.00),
                ],
                startPoint: .top, endPoint: .bottom
            )
        )
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SoftBlurBackdrop(imageURL: Manga.test.imageURL)
            .frame(height: 300)
    }
}
