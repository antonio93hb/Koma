//
//  CarouselBlurOverlay.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 14/8/25.
//

import SwiftUI

struct CarouselBlurOverlay: View {
    /// URL (String) de la imagen a difuminar
    let imageURL: String?
    /// Frame del carrusel publicado por la PreferenceKey
    let anchorFrame: CGRect
    /// Altura base a usar si aún no tenemos `anchorFrame.height`
    let fallbackHeight: CGFloat
    /// Margen extra arriba/abajo para que el efecto “entre” detrás de contenido
    let verticalPadding: CGFloat
    /// Opacidad del blur
    let opacity: Double

    var body: some View {
        let height = max(1, (anchorFrame.height == .zero ? fallbackHeight : anchorFrame.height) + verticalPadding * 2)

        let offsetY = (anchorFrame.minY.isInfinite ? -verticalPadding : anchorFrame.minY - verticalPadding)

        BlurredBackground(
            imageURL: imageURL,
            blur: 24,
            opacity: 1.0,
            height: height,
            fadeDistance: height * 0.20,
            showTopShadow: false
        )
        .overlay(
            Rectangle().fill(.ultraThinMaterial).opacity(0.55)
        )
        .saturation(1.1)
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.00),
                    .init(color: .black, location: 0.18),
                    .init(color: .black, location: 0.82),
                    .init(color: .clear, location: 1.00),
                ],
                startPoint: .top, endPoint: .bottom
            )
        )
        .opacity(opacity)
        .frame(height: height)
        .offset(y: offsetY)
        .ignoresSafeArea(edges: [.top, .horizontal])
        .allowsHitTesting(false)
        .zIndex(0)    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        CarouselBlurOverlay(
            imageURL: Manga.test.imageURL,
            anchorFrame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 250),
            fallbackHeight: 250,
            verticalPadding: 60,
            opacity: 0.2
        )
    }
    .frame(height: 400)
}
