import Foundation

enum HTTPMethod: String {
    case get
    case post
}

extension URLRequest {
    static func get(url: URL, method: HTTPMethod = .get, token: String? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    static func post<JSON>(url: URL, body: JSON, method: HTTPMethod = .post, token: String? = nil) -> URLRequest where JSON: Encodable {
        var request = URLRequest.get(url: url, method: method, token: token)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        return request
    }
}
