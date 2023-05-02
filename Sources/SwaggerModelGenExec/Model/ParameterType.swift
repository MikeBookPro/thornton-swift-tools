public enum ParameterType: String, ExpressibleByStringLiteral, Decodable {
    public typealias StringLiteralType = String
    case unknown
    case query
    case header
    case path
    case cookie
    
    public init(stringLiteral value: String) {
        switch value.lowercased() {
            case "query": self = .query
            case "path": self = .path
            case "header": self = .header
            case "cookie": self = .cookie
            default: self = .unknown
        }
    }
}
