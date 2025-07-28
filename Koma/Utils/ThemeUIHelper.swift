//
//  ThemeUIHelper.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 26/7/25.
//

import SwiftUI

struct ThemeUIHelper {
    static func style(for theme: String) -> TagStyle {
        switch theme.lowercased() {
        case "gore": return TagStyle(color: .red, icon: "drop.fill")
        case "military": return TagStyle(color: .green, icon: "shield.fill")
        case "mythology": return TagStyle(color: .purple, icon: "book.fill")
        case "psychological": return TagStyle(color: .pink, icon: "brain.head.profile")
        case "historical": return TagStyle(color: .brown, icon: "clock.fill")
        case "samurai": return TagStyle(color: .orange, icon: "sword")
        case "romantic subtext": return TagStyle(color: .pink, icon: "heart.fill")
        case "school": return TagStyle(color: .blue, icon: "building.columns.fill")
        case "adult cast": return TagStyle(color: .gray, icon: "person.2.fill")
        case "parody": return TagStyle(color: .orange, icon: "face.smiling")
        case "super power": return TagStyle(color: .cyan, icon: "bolt.fill")
        case "team sports": return TagStyle(color: .mint, icon: "sportscourt.fill")
        case "isekai": return TagStyle(color: .indigo, icon: "globe")
        case "vampire": return TagStyle(color: .red.opacity(0.8), icon: "drop.triangle.fill")
        case "space": return TagStyle(color: .blue.opacity(0.7), icon: "sparkles")
        case "idols (female)": return TagStyle(color: .pink, icon: "music.mic")
        case "idols (male)": return TagStyle(color: .purple, icon: "music.note")
        case "workplace": return TagStyle(color: .gray, icon: "briefcase.fill")
        case "survival": return TagStyle(color: .orange, icon: "figure.walk")
        case "childcare": return TagStyle(color: .pink, icon: "figure.2.and.child.holdinghands")
        case "iyashikei": return TagStyle(color: .mint, icon: "leaf.fill")
        case "reincarnation": return TagStyle(color: .purple, icon: "sparkles")
        case "showbiz": return TagStyle(color: .orange, icon: "star.fill")
        case "anthropomorphic": return TagStyle(color: .teal, icon: "pawprint.fill")
        case "love polygon": return TagStyle(color: .pink, icon: "heart.circle.fill")
        case "music": return TagStyle(color: .blue, icon: "music.note.list")
        case "mecha": return TagStyle(color: .gray, icon: "gearshape.2.fill")
        case "combat sports": return TagStyle(color: .red, icon: "figure.martial.arts")
        case "gag humor": return TagStyle(color: .orange, icon: "face.smiling")
        case "crossdressing": return TagStyle(color: .purple, icon: "person.fill.viewfinder")
        case "reverse harem": return TagStyle(color: .pink, icon: "person.3.fill")
        case "martial arts": return TagStyle(color: .orange, icon: "figure.martial.arts")
        case "visual arts": return TagStyle(color: .cyan, icon: "paintpalette.fill")
        case "harem": return TagStyle(color: .pink, icon: "person.2.fill")
        case "otaku culture": return TagStyle(color: .purple, icon: "gamecontroller.fill")
        case "time travel": return TagStyle(color: .indigo, icon: "clock.arrow.circlepath")
        case "video game": return TagStyle(color: .green, icon: "gamecontroller.fill")
        case "strategy game": return TagStyle(color: .teal, icon: "checkerboard.rectangle")
        case "mahou shoujo": return TagStyle(color: .pink, icon: "wand.and.stars")
        case "high stakes game": return TagStyle(color: .red, icon: "die.face.5.fill")
        case "cgdct": return TagStyle(color: .mint, icon: "face.smiling.inverse")
        case "organized crime": return TagStyle(color: .gray, icon: "handcuffs")
        case "detective": return TagStyle(color: .blue, icon: "magnifyingglass")
        case "performing arts": return TagStyle(color: .orange, icon: "theatermasks.fill")
        case "medical": return TagStyle(color: .red, icon: "cross.case.fill")
        case "memoir": return TagStyle(color: .brown, icon: "book.pages.fill")
        case "villainess": return TagStyle(color: .purple, icon: "crown.fill")
        case "racing": return TagStyle(color: .orange, icon: "car.fill")
        case "pets": return TagStyle(color: .teal, icon: "pawprint")
        case "magical sex shift": return TagStyle(color: .pink, icon: "sparkles")
        case "educational": return TagStyle(color: .blue, icon: "book.fill")
        default: return TagStyle(color: .secondary, icon: "tag.fill")
        }
    }
}
