import Foundation

enum NetworkError: LocalizedError {
    case nonHTTP
    case general(Error)
    case status(Int)
    case json(Error)
    
    var errorDescription: String? {
        switch self {
        case .nonHTTP:
            return String(localized: "Non HTTP response")
        case .general(let error):
            return String(localized: "General error \(error.localizedDescription)")
        case .status(let code):
            return String(localized: "Status code \(code)")
        case .json(let error):
            return String(localized: "JSON parsing error \(error.localizedDescription)")
        }
    }
}
