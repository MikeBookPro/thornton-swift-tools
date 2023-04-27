public enum HttpStatusCode: ExpressibleByStringLiteral, Decodable, Hashable {
    public typealias StringLiteralType = String
    
    case unknown(String)
    case informational(Int)
    case successful(Int)
    case redirection(Int)
    case clientError(Int)
    case serverError(Int)
    
    public init(stringLiteral value: String) {
        let intValue: Int = .init(value) ?? .zero
        switch intValue {
            case 100...199: self = .informational(intValue)
            case 200...299: self = .successful(intValue)
            case 300...399: self = .redirection(intValue)
            case 400...499: self = .clientError(intValue)
            case 500...599: self = .serverError(intValue)
            default: self = .unknown(value)
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
            case let .unknown(value): hasher.combine(value)
            case let .informational(value): hasher.combine(value)
            case let .successful(value): hasher.combine(value)
            case let .redirection(value): hasher.combine(value)
            case let .clientError(value): hasher.combine(value)
            case let .serverError(value): hasher.combine(value)
        }
    }
}
