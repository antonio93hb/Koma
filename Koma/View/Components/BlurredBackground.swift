//
//  BlurredBackground.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 25/7/25.
//
import SwiftUI

struct BlurredBackground: View {
    // Fuente
    let imageURL: String?

    // Ajustes configurables
    let blur: CGFloat
    let opacity: CGFloat
    let height: CGFloat?
    let fadeDistance: CGFloat
    let showTopShadow: Bool

    // Inicializador con valores por defecto
    init(
        imageURL: String?,
        blur: CGFloat = 40,
        opacity: CGFloat = 0.18,
        height: CGFloat? = nil,
        fadeDistance: CGFloat = 120,
        showTopShadow: Bool = true
    ) {
        self.imageURL = imageURL
        self.blur = blur
        self.opacity = opacity
        self.height = height
        self.fadeDistance = fadeDistance
        self.showTopShadow = showTopShadow
    }
    var body: some View {
        Group {
            if let urlString = imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        BlurredImage(image: img,
                                     blur: blur,
                                     opacity: opacity,
                                     height: height,
                                     fadeDistance: fadeDistance,
                                     showTopShadow: showTopShadow)
                    default:
                        Color.clear
                    }
                }
            } else {
                Color.clear
            }
        }
    }
}

// Vista interna sencilla para no mezclar mucha lógica en el body principal
private struct BlurredImage: View {
    let image: Image
    let blur: CGFloat
    let opacity: CGFloat
    let height: CGFloat?
    let fadeDistance: CGFloat
    let showTopShadow: Bool

    @ViewBuilder
    var body: some View {
        let blurredImageBase = image
            .resizable()
            .scaledToFill()
            .blur(radius: blur)
            .opacity(opacity)

        if let heightValue = height {
            blurredImageBase
                .frame(height: heightValue)
                // Recorte con desvanecido hacia abajo (igual que en Home)
                .mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .black, location: 0.0),
                            .init(color: .black,
                                  location: max(0, (heightValue - fadeDistance) / max(1, heightValue))),
                            .init(color: .clear, location: 1.0)
                        ]),
                        startPoint: .top, endPoint: .bottom
                    )
                )
                // Sombra suave arriba (opcional)
                .overlay(alignment: .top) {
                    if showTopShadow {
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .black.opacity(0.00), location: 0.0),
                                .init(color: .black.opacity(0.22), location: 0.18),
                                .init(color: .black.opacity(0.18), location: 0.80),
                                .init(color: .black.opacity(0.00), location: 1.00),
                            ]),
                            startPoint: .top, endPoint: .bottom
                        )
                    }
                }
                .allowsHitTesting(false)
                .clipped()
        } else {
            // Versión “full screen”
            blurredImageBase
                .allowsHitTesting(false)
        }
    }
}

#Preview {
    BlurredBackground(imageURL: Manga.test.imageURL,
                      blur: 40,
                      opacity: 0.18,
                      fadeDistance: 120,
                      showTopShadow: true)
}
