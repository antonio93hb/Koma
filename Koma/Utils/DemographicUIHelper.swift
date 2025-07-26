//
//  DemographicUIHelper.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 26/7/25.
//

import SwiftUI

struct DemographicUIHelper {
    struct DemographicStyle {
        let color: Color
        let icon: String
    }

    static func style(for demographic: String) -> DemographicStyle {
        switch demographic.lowercased() {
        case "seinen":
            return DemographicStyle(color: .gray, icon: "person.2.fill")
        case "shounen":
            return DemographicStyle(color: .blue, icon: "figure.run")
        case "shoujo":
            return DemographicStyle(color: .pink, icon: "heart.fill")
        case "josei":
            return DemographicStyle(color: .purple, icon: "person.crop.circle.badge.checkmark")
        case "kids":
            return DemographicStyle(color: .green, icon: "figure.and.child.holdinghands")
        default:
            return DemographicStyle(color: .secondary, icon: "tag.fill")
        }
    }
}
