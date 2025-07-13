//
//  MangaCardCarrusel.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 20/6/25.
//
import SwiftUI

struct MangaCardCarrusel: View {
    
    let manga: Manga

    var body: some View {
        ZStack {
            // Fondo difuminado (detrás de la tarjeta)
            AsyncImage(url: URL(string: manga.imageURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 10)
                    .opacity(0.1)
                    .offset(y: 10)
                    .overlay(
                            // Capa sutil para suavizar los bordes
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(.systemBackground), // más integrado con el fondo
                                    Color(.systemBackground).opacity(0.0),
                                    Color(.systemBackground)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
            } placeholder: {
                Color.clear
            }
            .frame(height: 180)
           
            
            ZStack(alignment: .bottomLeading) {
                
                // Imagen de fondo con blur
                AsyncImage(url: URL(string: manga.imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 1)
                        .overlay(Color.black.opacity(0.3)) // Degradado oscuro
                } placeholder: {
                    Color.gray
                }
                .frame(height: 180)
                .clipped()
                
                HStack(alignment: .top) {
                    MangaImg(manga: manga)
                        .frame(width: 50, height: 70)

                    VStack(alignment: .leading) {
                        Text(manga.title)
                            .font(.headline)
                            .bold()
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x:1, y:1)
                            .shadow(color: .black, radius: 2, x: -1, y: -1)
                        
                        Text(manga.status.capitalized) // finished / ongoing
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x:1, y:1)
                            .shadow(color: .black, radius: 2, x: -1, y: -1)
                    }
                }
                .padding()
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(radius: 4)
        }
    }
}

#Preview {
    MangaCardCarrusel(manga: .test)
}
