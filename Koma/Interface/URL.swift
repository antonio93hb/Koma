import Foundation

extension URL {
    
    //  https://mymanga-acacademy-5607149ebe3d.herokuapp.com/list/mangas
    
    static func allMangas(page: Int) -> URL {
        createURL(path: "/list/mangas", queryItems: [
            URLQueryItem(name: "page", value: "\(page)")
        ])
    }
    
    // https://mymanga-acacademy-5607149ebe3d.herokuapp.com/list/bestMangas
    
    static func bestMangas() -> URL {
        createURL(path: "/list/bestMangas")
    }
    
    private static func createURL(path: String, queryItems: [URLQueryItem]? = nil) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "mymanga-acacademy-5607149ebe3d.herokuapp.com"
        components.path = path
        components.queryItems = queryItems
        
        guard let url = components.url else {
            fatalError("Could not create URL")
        }
        return url
    }
}
