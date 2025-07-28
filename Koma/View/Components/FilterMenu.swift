//
//  FilterMenu.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 28/7/25.
//
import SwiftUI

struct FilterMenu: View {
    let title: String
    let items: [String]
    @Binding var selectedItems: [String]
    let styleProvider: (String) -> TagStyle
    
    var body: some View {
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
                        if selectedItems.contains(item) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
        } label: {
            if let lastSelected = selectedItems.last {
                let style = styleProvider(lastSelected)
                AppGlassButton(title: lastSelected, systemImage: style.icon) { }
            } else {
                AppGlassButton(title: title, systemImage: "line.3.horizontal.decrease.circle") { }
            }
        }
        .padding(.bottom, 4)
    }
}
