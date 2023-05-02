public struct SchemaProperty: Decodable, SchemaReferencing {
    public let `type`: String?
    public let `format`: String?
    public let items: SchemaProperty.Item?
    public var ref: String?
    
    enum CodingKeys: String, CodingKey {
        case `type`
        case `format`
        case items
        case ref = "$ref"
    }
    
    public struct Item: Decodable, SchemaReferencing {
        public var ref: String?
        
        enum CodingKeys: String, CodingKey {
            case ref = "$ref"
        }
    }
}
