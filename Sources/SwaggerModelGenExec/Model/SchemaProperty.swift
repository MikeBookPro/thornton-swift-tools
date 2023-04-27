public struct SchemaProperty: Codable, SchemaReferencing {
    public let `type`: String
    public let `format`: String?
    public let items: SchemaPropertyItem?
    public let `enum`: [String]?
    public var ref: String?
    
    // TODO: Move this out of model Codable and into own `SwiftBuilder`
    var swiftTypeName: String? {
        let reference: SchemaReferencing? = (ref != nil) ? self : self.items
        if let reference { return SchemaProperty.swift(nameForReferenced: reference) }
        return SchemaPropertyType(rawValue: self.type)?.swiftName
    }
    
    enum CodingKeys: String, CodingKey {
        case `type`
        case `format`
        case items
        case `enum`
        case ref = "$ref"
    }
}
