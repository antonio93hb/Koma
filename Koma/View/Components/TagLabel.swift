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

    var body: some View {
        Label(text, systemImage: style.icon)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(style.color.opacity(0.15))
            )
            .foregroundColor(style.color)
    }
}
