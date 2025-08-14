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
        // Altura efectiva: si aún no hay frame, usamos el fallback.
        let height = max(1, (anchorFrame.height == .zero ? fallbackHeight : anchorFrame.height) + verticalPadding * 2)

        // Offset vertical: anclamos el blur al TOP del carrusel y lo desplazamos
        // hacia arriba `verticalPadding` para que “entre” detrás de elementos cercanos.
        let offsetY = (anchorFrame.minY.isInfinite ? -verticalPadding : anchorFrame.minY - verticalPadding)

        SoftBlurBackdrop(imageURL: imageURL)
            .opacity(opacity)
            .frame(height: height)
            .offset(y: offsetY)
            .ignoresSafeArea(edges: [.top, .horizontal])
            .allowsHitTesting(false)
            .zIndex(0)
    }
}

#Preview {
    ZStack {
        // Fondo simulado para ver contraste
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
