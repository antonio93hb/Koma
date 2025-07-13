import Foundation

extension URLSession {
    
    func getData(from url: URL) async throws(NetworkError) -> (
        data: Data,
        response: HTTPURLResponse
    ) {
        do {
            let (data, response) = try await data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.nonHTTP
            }
            return (data, httpResponse)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw .general(error)
        }
    }
    
    func getData(for request: URLRequest) async throws(NetworkError) -> (
        data: Data,
        response: HTTPURLResponse
    ) {
        do {
            let (data, response) = try await data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.nonHTTP
            }
            return (data, httpResponse)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw .general(error)
        }
    }
}
