//
//  GenreUIHelper.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 26/7/25.
//

import SwiftUI

struct GenreUIHelper {
    static func style(for genre: String) -> TagStyle {
        switch genre {
        case "Action":
            return TagStyle(color: .red, icon: "flame.fill")
        case "Adventure":
            return TagStyle(color: .orange, icon: "map.fill")
        case "Award Winning":
            return TagStyle(color: .orange, icon: "star.fill")
        case "Drama":
            return TagStyle(color: .purple, icon: "theatermasks.fill")
        case "Fantasy":
            return TagStyle(color: .indigo, icon: "wand.and.stars")
        case "Horror":
            return TagStyle(color: .black, icon: "eye.fill")
        case "Supernatural":
            return TagStyle(color: .mint, icon: "sparkles")
        case "Mystery":
            return TagStyle(color: .blue, icon: "magnifyingglass.circle.fill")
        case "Slice of Life":
            return TagStyle(color: .teal, icon: "leaf.fill")
        case "Comedy":
            return TagStyle(color: .pink, icon: "face.smiling.fill")
        case "Sci-Fi":
            return TagStyle(color: .cyan, icon: "antenna.radiowaves.left.and.right")
        case "Suspense":
            return TagStyle(color: .gray, icon: "exclamationmark.triangle.fill")
        case "Sports":
            return TagStyle(color: .green, icon: "figure.run")
        case "Ecchi":
            return TagStyle(color: .pink, icon: "heart.circle.fill")
        case "Romance":
            return TagStyle(color: .red, icon: "heart.fill")
        case "Girls Love":
            return TagStyle(color: .purple, icon: "heart.text.square.fill")
        case "Boys Love":
            return TagStyle(color: .blue, icon: "heart.text.square")
        case "Gourmet":
            return TagStyle(color: .brown, icon: "fork.knife")
        case "Erotica":
            return TagStyle(color: .pink.opacity(0.7), icon: "flame.circle.fill")
        case "Hentai":
            return TagStyle(color: .red.opacity(0.7), icon: "eye.trianglebadge.exclamationmark.fill")
        case "Avant Garde":
            return TagStyle(color: .orange.opacity(0.8), icon: "paintpalette.fill")
        default:
            return TagStyle(color: .gray, icon: "tag.fill")
        }
    }
}

extension GenreUIHelper {
    static let allGenres: [String] = [
        "Action", "Adventure", "Award Winning", "Drama", "Fantasy", "Horror",
        "Supernatural", "Mystery", "Slice of Life", "Comedy", "Sci-Fi",
        "Suspense", "Sports", "Ecchi", "Romance", "Girls Love", "Boys Love",
        "Gourmet", "Erotica", "Hentai", "Avant Garde"
    ]
}
