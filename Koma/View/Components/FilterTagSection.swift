//
//  FilterTagSection.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 29/7/25.
//
import SwiftUI

struct FilterTagSection: View {
    let title: String
    @Binding var items: [String]
    let styleProvider: (String) -> TagStyle
    
    var body: some View {
        if !items.isEmpty {
            HStack(alignment: .center) {
                Text("\(title):")
                    .font(.subheadline)
                    .bold()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(items, id: \.self) { item in
                            TagLabel(
                                text: item,
                                style: styleProvider(item),
                                onRemove: {
                                    items.removeAll { $0 == item }
                                }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
