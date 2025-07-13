import Foundation

enum HTTPMethod: String {
    case get
    case post
}

extension URLRequest {
    static func get (_ url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("aplication/json", forHTTPHeaderField: "Accept")
        return request
    }
}
