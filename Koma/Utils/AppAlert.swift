//
//  AlertType.swift
//  Koma
//
//  Created by Antonio Hernández Barbadilla on 24/7/25.
//

import SwiftUI

enum AppAlert: Identifiable {
    case successVolumes
    case invalidInput
    case saved
    case deleted
    case failedToSave
    case failedToDelete

    var id: Int { hashValue }

    var alert: Alert {
        switch self {
        case .successVolumes:
            return Alert(title: Text("Actualizado"), message: Text("Los tomos se han modificado correctamente."))

        case .invalidInput:
            return Alert(title: Text("Error"), message: Text("Introduce un número válido."))

        case .saved:
            return Alert(title: Text("Guardado"), message: Text("Este manga ha sido guardado en favoritos."))

        case .deleted:
            return Alert(title: Text("Eliminado"), message: Text("Este manga ha sido eliminado de favoritos."))

        case .failedToSave:
            return Alert(title: Text("Error"), message: Text("No se ha podido guardar el manga. Inténtalo más tarde."))

        case .failedToDelete:
            return Alert(title: Text("Error"), message: Text("No se ha podido eliminar el manga."))
        }
    }
}
