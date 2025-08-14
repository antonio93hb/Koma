//
//  CarouselPreferenceKey.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 14/8/25.
//

import SwiftUI

/// Publica la URL (String) de la portada centrada en el carrusel
struct CenteredCoverPreferenceKey: PreferenceKey {
    static var defaultValue: String? = nil
    static func reduce(value: inout String?, nextValue: () -> String?) {
        if let new = nextValue() { value = new }
    }
}

/// Publica el frame (CGRect) del carrusel para posicionar el fondo
struct CarouselFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
