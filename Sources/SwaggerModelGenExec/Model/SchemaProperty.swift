public struct SchemaProperty: Decodable, SchemaReferencing {
    public let `type`: String?
    public let `format`: String?
    public let items: SchemaProperty.Item?
    public var ref: String?
    
    // TODO: Move this out of model Codable and into own `SwiftBuilder`
//    var swiftTypeName: String? {
//        let reference: SchemaReferencing? = (ref != nil) ? self : self.items
//        if let reference { return SchemaProperty.swift(nameForReferenced: reference) }
//        if let type {  return SchemaPropertyType(rawValue: type)?.swiftName }
//        return ""
//    }
    
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
