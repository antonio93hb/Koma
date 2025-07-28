//
//  DemographicUIHelper.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 26/7/25.
//

import SwiftUI

struct DemographicUIHelper {
    static func style(for demographic: String) -> TagStyle {
        switch demographic.lowercased() {
        case "seinen":
            return TagStyle(color: .gray, icon: "person.3.fill")
        case "shounen":
            return TagStyle(color: .blue, icon: "figure.run.circle.fill")
        case "shoujo":
            return TagStyle(color: .pink, icon: "heart.circle.fill")
        case "josei":
            return TagStyle(color: .purple, icon: "person.fill")
        case "kids":
            return TagStyle(color: .green, icon: "figure.and.child.holdinghands")
        default:
            return TagStyle(color: .secondary, icon: "tag.fill")
        }
    }
}
