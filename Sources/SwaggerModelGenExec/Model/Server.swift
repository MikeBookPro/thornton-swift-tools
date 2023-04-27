public struct Server: Codable {
    public let urlString: String
    
    enum CodingKeys: String, CodingKey {
        case urlString = "url"
    }
}
