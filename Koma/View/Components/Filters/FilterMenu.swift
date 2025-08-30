//
//  FilterMenu.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 28/7/25.
//
import SwiftUI

struct FilterMenu: View {
    let title: LocalizedStringKey
    let items: [String]
    @Binding var selectedItems: [String]
    let styleProvider: (String) -> TagStyle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Menu {
                    ForEach(items, id: \.self) { item in
                        Button {
                            if selectedItems.contains(item) {
                                selectedItems.removeAll { $0 == item }
                            } else {
                                selectedItems.append(item)
                            }
                        } label: {
                            HStack {
                                let style = styleProvider(item)
                                Label(item, systemImage: style.icon)
                                    .foregroundColor(style.color)
                            }
                        }
                    }
                } label: {
                    AppGlassButton(titleKey: title) { }
                }
            }
        }
    }
}

#Preview {
    FilterMenu(
        title: "Género",
        items: ["Action","Adventure","Drama","Fantasy","Horror"],
        selectedItems: .constant(["Drama"]),
        styleProvider: { GenreUIHelper.style(for: $0) }
    )
}

