//
//  TagLabel.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 28/7/25.
//

import SwiftUI

struct TagStyle {
    let color: Color
    let icon: String
}

struct TagLabel: View {
    let text: String
    let style: TagStyle
    var onRemove: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 4) {
            Label(text, systemImage: style.icon)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(style.color.opacity(0.2))
                .clipShape(Capsule())

            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        TagLabel(
            text: "Drama",
            style: TagStyle(color: .blue, icon: "film")
        )

        TagLabel(
            text: "Horror",
            style: TagStyle(color: .red, icon: "drop.fill"),
            onRemove: { print("Etiqueta eliminada") }
        )
    }
    .padding()
}
