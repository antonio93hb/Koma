//
//  AlertType.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 24/7/25.
//

import Foundation
import SwiftUI

enum AppAlert: Identifiable {
    case success
    case invalid

    var id: Int { hashValue }

    var alert: Alert {
        switch self {
        case .success:
            return Alert(
                title: Text("Guardado con éxito"),
                dismissButton: .default(Text("Aceptar"))
            )
        case .invalid:
            return Alert(
                title: Text("Número inválido"),
                message: Text("Introduce un número válido entre 0 y el total de tomos."),
                dismissButton: .default(Text("Aceptar"))
            )
        }
    }
}
