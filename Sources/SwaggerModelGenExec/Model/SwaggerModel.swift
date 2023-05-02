import Foundation

struct SwaggerModel: Decodable {
    public let openAPIVersion: String
    public let servers: [Server]
    public let tags: [Tag]
    public let paths: [String: Endpoint]
    public let components: Components
    
    enum CodingKeys: String, CodingKey {
        case openAPIVersion = "openapi"
        case servers
        case tags
        case paths
        case components
        // case info // TODO: Implement later
        // case externalDocs // TODO: Implement later
    }
}

