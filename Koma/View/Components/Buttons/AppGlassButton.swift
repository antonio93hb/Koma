//
//  AppGlassButton.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 26/7/25.
//

import SwiftUI

struct AppGlassButton: View {
    var titleKey: LocalizedStringKey
    var systemImage: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = systemImage {
                    Image(systemName: icon)
                }
                Text(titleKey)
            }
            .font(.subheadline)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
            .shadow(radius: 1)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    AppGlassButton(titleKey: "add_button", systemImage: "books.vertical") {
        print("Añadir tapped")
    }
    .padding()
}
