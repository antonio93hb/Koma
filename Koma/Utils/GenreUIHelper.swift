//
//  GenreUIHelper.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 26/7/25.
//

import SwiftUI

struct GenreUIHelper {
    struct GenreStyle {
        let color: Color
        let icon: String
    }

    static func style(for genre: String) -> GenreStyle {
        switch genre {
        case "Action":
            return GenreStyle(color: .red, icon: "flame.fill")
        case "Adventure":
            return GenreStyle(color: .orange, icon: "map.fill")
        case "Award Winning":
            return GenreStyle(color: .orange, icon: "star.fill")
        case "Drama":
            return GenreStyle(color: .purple, icon: "theatermasks.fill")
        case "Fantasy":
            return GenreStyle(color: .indigo, icon: "wand.and.stars")
        case "Horror":
            return GenreStyle(color: .black, icon: "eye.fill")
        case "Supernatural":
            return GenreStyle(color: .mint, icon: "sparkles")
        case "Mystery":
            return GenreStyle(color: .blue, icon: "magnifyingglass.circle.fill")
        case "Slice of Life":
            return GenreStyle(color: .teal, icon: "leaf.fill")
        case "Comedy":
            return GenreStyle(color: .pink, icon: "face.smiling.fill")
        case "Sci-Fi":
            return GenreStyle(color: .cyan, icon: "antenna.radiowaves.left.and.right")
        case "Suspense":
            return GenreStyle(color: .gray, icon: "exclamationmark.triangle.fill")
        case "Sports":
            return GenreStyle(color: .green, icon: "figure.run")
        case "Ecchi":
            return GenreStyle(color: .pink, icon: "heart.circle.fill")
        case "Romance":
            return GenreStyle(color: .red, icon: "heart.fill")
        case "Girls Love":
            return GenreStyle(color: .purple, icon: "heart.text.square.fill")
        case "Boys Love":
            return GenreStyle(color: .blue, icon: "heart.text.square")
        case "Gourmet":
            return GenreStyle(color: .brown, icon: "fork.knife")
        case "Erotica":
            return GenreStyle(color: .pink.opacity(0.7), icon: "flame.circle.fill")
        case "Hentai":
            return GenreStyle(color: .red.opacity(0.7), icon: "eye.trianglebadge.exclamationmark.fill")
        case "Avant Garde":
            return GenreStyle(color: .orange.opacity(0.8), icon: "paintpalette.fill")
        default:
            return GenreStyle(color: .gray, icon: "tag.fill")
        }
    }
}
