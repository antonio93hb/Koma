//
//  BlurredBackground.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 25/7/25.
//
import SwiftUI

struct BlurredBackground: View {
    let imageURL: String

    var body: some View {
        if let url = URL(string: imageURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 40)
                        .opacity(0.3)
                        .ignoresSafeArea()
                default:
                    EmptyView()
                }
            }
        }
    }
}
