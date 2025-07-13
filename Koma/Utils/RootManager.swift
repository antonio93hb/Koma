import Foundation

@Observable
final class RootManager {
    
    enum Views {
        case welcome
        case login
        case content
    }
    var currentView: Views = .welcome
}


