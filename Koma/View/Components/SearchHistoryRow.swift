//
//  SearchView.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 29/7/25.
//



import SwiftUI

struct SearchHistoryRow: View {
    let history: SearchDB
    let onDelete: () -> Void
    let onSelect: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(history.query.isEmpty ? "Sin título" : history.query)
                    .font(.headline)
                let filters = (history.genres + history.themes + history.demographics).joined(separator: ", ")
                if !filters.isEmpty {
                    Text(filters)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

#Preview {
    SearchHistoryRow(
        history: SearchDB(
            query: "Naruto",
            genres: ["Action", "Adventure"],
            themes: ["Ninja"],
            demographics: ["Shounen"]
        ),
        onDelete: {},
        onSelect: {}
    )
    .padding()
    .previewLayout(.sizeThatFits)
}
