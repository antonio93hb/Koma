import Foundation

enum NetworkError: LocalizedError {
    case nonHTTP
    case general(Error)
    case status(Int)
    case json(Error)
    
    var errorDescription: String? {
        switch self {
        case .nonHTTP:
            return String(localized: "network_error_non_http")
        case .general(let error):
            return String(localized: "network_error_general \(error.localizedDescription)")
        case .status(let code):
            return String(localized: "network_error_status_code \(code)")
        case .json(let error):
            return String(localized: "network_error_json \(error.localizedDescription)")
        }
    }
}
