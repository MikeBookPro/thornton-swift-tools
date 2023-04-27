public struct Server: Decodable {
    public let urlString: String
    
    enum CodingKeys: String, CodingKey {
        case urlString = "url"
    }
}
