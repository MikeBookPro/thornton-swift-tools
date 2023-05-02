public struct Schema: Decodable {
    public let `type`: String
    public let properties: [String: SchemaProperty]?
    public let enumCases: [String]?
    
    enum CodingKeys: String, CodingKey {
        case `type`
        case properties
        case enumCases = "enum"
    }
}
