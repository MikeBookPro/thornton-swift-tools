public struct SchemaPropertyItem: Codable, SchemaReferencing {
    public var ref: String?
    
    enum CodingKeys: String, CodingKey {
        case ref = "$ref"
    }
}
