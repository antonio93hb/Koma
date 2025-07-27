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
            return DemographicStyle(color: .gray, icon: "person.3.fill")
        case "shounen":
            return DemographicStyle(color: .blue, icon: "figure.run.circle.fill")
        case "shoujo":
            return DemographicStyle(color: .pink, icon: "heart.circle.fill")
        case "josei":
            return DemographicStyle(color: .purple, icon: "person.fill")
        case "kids":
            return DemographicStyle(color: .green, icon: "figure.and.child.holdinghands")
        default:
            return DemographicStyle(color: .secondary, icon: "tag.fill")
        }
    }
}
