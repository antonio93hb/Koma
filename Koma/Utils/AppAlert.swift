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
            return Alert(title: Text("updated_title"), message: Text("updated_message"))

        case .invalidInput:
            return Alert(title: Text("error_title"), message: Text("invalid_input_message"))

        case .saved:
            return Alert(title: Text("saved_title"), message: Text("saved_message"))

        case .deleted:
            return Alert(title: Text("deleted"), message: Text("deleted_message"))

        case .failedToSave:
            return Alert(title: Text("error_title"), message: Text("failed_to_save_message"))

        case .failedToDelete:
            return Alert(title: Text("error_title"), message: Text("failed_to_delete_message"))
        }
    }
}
