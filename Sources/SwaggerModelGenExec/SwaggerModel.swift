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
        //        case info
        //        case externalDocs
    }
}


enum SchemaPropertyType: String {
    case boolean
    case string
    //    case integer(format: IntComponentFormat?)
    //    case number(format: NumberComponentFormat?)
    //    case enumeration(name: String)
    //    case array(element: String)
    
    var swiftName: String {
        switch self {
            case .boolean: return String(describing: Bool.self)
            case .string: return String(describing: String.self)
                //            case .integer(let componentFormat): return componentFormat?.swiftName ?? String(describing: Int.self)
                //            case .number(let componentFormat): return componentFormat?.swiftName ?? String(describing: Double.self)
        }
    }
    
    //    init?(`type` typeName: String, `format` typeFormatName: String?) {
    //        switch typeName {
    //            case "boolean": self = .boolean
    //            case "string": self = .string
    ////            case "string": self = .string(format: .init(format: typeFormatName))
    //            case "integer": self = .integer(format: .init(format: typeFormatName))
    ////            case "enum": self = .enumeration(name: name)
    ////            case "array": self = .array(element: name)
    //            default: return nil
    //        }
    //    }
    
    enum StringComponentFormat: String {
        case dateTime
        case uri
        
        init?(`format`: String?) {
            guard let format, let selected = Self(rawValue: format) else { return nil }
            self = selected
        }
        
        var swiftName: String {
            switch self {
                case .dateTime: return String(describing: Date.self)
                case .uri: return String(describing: URL.self)
            }
        }
    }
    
    enum IntComponentFormat: String {
        case int32
        case int64
        
        init?(`format`: String?) {
            guard let format, let selected = Self(rawValue: format) else { return nil }
            self = selected
        }
        
        var swiftName: String {
            switch self {
                case .int64: return String(describing: Int64.self)
                case .int32: return String(describing: Int32.self)
            }
        }
    }
    
    enum NumberComponentFormat: String {
        case float
        case double
        
        init?(`format`: String?) {
            guard let format, let selected = Self(rawValue: format) else { return nil }
            self = selected
        }
        
        var swiftName: String {
            switch self {
                case .float: return String(describing: Float.self)
                case .double: return String(describing: Double.self)
            }
        }
    }
    
}


