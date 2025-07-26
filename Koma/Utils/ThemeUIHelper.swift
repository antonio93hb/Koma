//
//  ThemeUIHelper.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 26/7/25.
//

import SwiftUI

struct ThemeUIHelper {
    struct ThemeStyle {
        let name: String
        let color: Color
        let icon: String
    }

    static func style(for theme: String) -> ThemeStyle {
        switch theme.lowercased() {
        case "gore": return .init(name: "Gore", color: .red, icon: "drop.fill")
        case "military": return .init(name: "Militar", color: .green, icon: "shield.fill")
        case "mythology": return .init(name: "Mitología", color: .purple, icon: "book.fill")
        case "psychological": return .init(name: "Psicológico", color: .pink, icon: "brain.head.profile")
        case "historical": return .init(name: "Histórico", color: .brown, icon: "clock.fill")
        case "samurai": return .init(name: "Samurái", color: .orange, icon: "sword")
        case "romantic subtext": return .init(name: "Romance", color: .pink, icon: "heart.fill")
        case "school": return .init(name: "Escolar", color: .blue, icon: "building.columns.fill")
        case "adult cast": return .init(name: "Adultos", color: .gray, icon: "person.2.fill")
        case "parody": return .init(name: "Parodia", color: .orange, icon: "face.smiling")
        case "super power": return .init(name: "Poderes", color: .cyan, icon: "bolt.fill")
        case "team sports": return .init(name: "Deportes", color: .mint, icon: "sportscourt.fill")
        case "isekai": return .init(name: "Isekai", color: .indigo, icon: "globe")
        case "vampire": return .init(name: "Vampiros", color: .red.opacity(0.8), icon: "drop.triangle.fill")
        case "space": return .init(name: "Espacio", color: .blue.opacity(0.7), icon: "sparkles")
        case "idols (female)": return .init(name: "Idols Femeninas", color: .pink, icon: "music.mic")
        case "idols (male)": return .init(name: "Idols Masculinos", color: .purple, icon: "music.note")
        case "workplace": return .init(name: "Trabajo", color: .gray, icon: "briefcase.fill")
        case "survival": return .init(name: "Supervivencia", color: .orange, icon: "figure.walk")
        case "childcare": return .init(name: "Cuidado Infantil", color: .pink, icon: "figure.2.and.child.holdinghands")
        case "iyashikei": return .init(name: "Iyashikei", color: .mint, icon: "leaf.fill")
        case "reincarnation": return .init(name: "Reencarnación", color: .purple, icon: "sparkles")
        case "showbiz": return .init(name: "Espectáculo", color: .orange, icon: "star.fill")
        case "anthropomorphic": return .init(name: "Antropomórfico", color: .teal, icon: "pawprint.fill")
        case "love polygon": return .init(name: "Polígono Amoroso", color: .pink, icon: "heart.circle.fill")
        case "music": return .init(name: "Música", color: .blue, icon: "music.note.list")
        case "mecha": return .init(name: "Mecha", color: .gray, icon: "gearshape.2.fill")
        case "combat sports": return .init(name: "Deportes de Combate", color: .red, icon: "figure.martial.arts")
        case "gag humor": return .init(name: "Comedia", color: .orange, icon: "face.smiling")
        case "crossdressing": return .init(name: "Crossdressing", color: .purple, icon: "person.fill.viewfinder")
        case "reverse harem": return .init(name: "Reverse Harem", color: .pink, icon: "person.3.fill")
        case "martial arts": return .init(name: "Artes Marciales", color: .orange, icon: "figure.martial.arts")
        case "visual arts": return .init(name: "Artes Visuales", color: .cyan, icon: "paintpalette.fill")
        case "harem": return .init(name: "Harem", color: .pink, icon: "person.2.fill")
        case "otaku culture": return .init(name: "Cultura Otaku", color: .purple, icon: "gamecontroller.fill")
        case "time travel": return .init(name: "Viajes en el Tiempo", color: .indigo, icon: "clock.arrow.circlepath")
        case "video game": return .init(name: "Videojuego", color: .green, icon: "gamecontroller.fill")
        case "strategy game": return .init(name: "Estrategia", color: .teal, icon: "checkerboard.rectangle")
        case "mahou shoujo": return .init(name: "Mahou Shoujo", color: .pink, icon: "wand.and.stars")
        case "high stakes game": return .init(name: "Juegos de Alto Riesgo", color: .red, icon: "die.face.5.fill")
        case "cgdct": return .init(name: "CGDCT", color: .mint, icon: "face.smiling.inverse")
        case "organized crime": return .init(name: "Crimen Organizado", color: .gray, icon: "handcuffs")
        case "detective": return .init(name: "Detective", color: .blue, icon: "magnifyingglass")
        case "performing arts": return .init(name: "Artes Escénicas", color: .orange, icon: "theatermasks.fill")
        case "medical": return .init(name: "Médico", color: .red, icon: "cross.case.fill")
        case "memoir": return .init(name: "Memorias", color: .brown, icon: "book.pages.fill")
        case "villainess": return .init(name: "Villana", color: .purple, icon: "crown.fill")
        case "racing": return .init(name: "Carreras", color: .orange, icon: "car.fill")
        case "pets": return .init(name: "Mascotas", color: .teal, icon: "pawprint")
        case "magical sex shift": return .init(name: "Cambio Mágico de Sexo", color: .pink, icon: "sparkles")
        case "educational": return .init(name: "Educativo", color: .blue, icon: "book.fill")
        default: return .init(name: theme.capitalized, color: .secondary, icon: "tag.fill")
        }
    }
}
