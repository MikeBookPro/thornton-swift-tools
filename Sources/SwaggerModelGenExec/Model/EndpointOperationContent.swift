public struct EndpointOperationContent: Decodable {
    public let description: String
    public let content: [String: SchemaProperty]? // EncodingType
}

//public enum ContentEncoding: String, ExpressibleByStringLiteral, Decodable {
//
//    public typealias StringLiteralType = String
//
//    case any = "*/*"
//    case json = "application/json"
//    case xml = "application/xml"
//    case plainText = "text/plain"
//    case htmlText = "text/html"
//    case octetStream = "application/octet-stream"
//    case formData = "multipart/form-data"
//    case formURL = "application/x-www-form-urlencoded"
//
//    public init(stringLiteral value: String) {
//        guard let operation = Self(rawValue: value.lowercased()) else {
//            self = .any
//            return
//        }
//        self = operation
//    }
//}
