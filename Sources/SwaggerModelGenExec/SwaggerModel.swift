import Foundation


struct SwaggerModel: Codable {
    public let openAPIVersion: String
    public let servers: [Server]
    public let tags: [Tag]
    //    public let paths: String
    public let components: Components
    
    enum CodingKeys: String, CodingKey {
        case openAPIVersion = "openapi"
        case servers
        case tags
        //        case paths
        case components
        //        case info
        //        case externalDocs
    }
}

struct Server: Codable {
    public let urlString: String
    
    enum CodingKeys: String, CodingKey {
        case urlString = "url"
    }
}

struct Tag: Codable, CustomStringConvertible {
    public let name: String
    let descr: String
    
    public var description: String { descr }
    
    enum CodingKeys: String, CodingKey {
        case name
        case descr = "description"
    }
}

struct Path {
    public let tags: [String]?
    public let summary: String?
    let descr: String?
    public let operationID: String?
    //    public let parameters: String?
    //    public let responses: String?
    
    enum CodingKeys: String, CodingKey {
        case tags
        case summary
        case descr = "description"
        case operationID = "operationId"
        case parameters
        case responses
    }
}

struct Components: Codable {
    public let schemas: [String: Schema]
    
    var swiftCode: [String] {
        self.schemas.keys
            .sorted()
            .reduce(["import Foundation\n"]) { partialResult, structName in
                guard let schema = self.schemas[structName] else { return partialResult }
                let code = """
                public struct \(structName): Codable {
                    \(schema.swiftInstanceVariables.joined(separator: "\n\t"))
                
                    \(schema.swiftInitializer)
                }
                
                """
                return partialResult + [code]
            }
    }
}

struct Schema: Codable {
    public let `type`: String
    public let properties: [String: SchemaProperty]
    
    private var variableNameAndTypes: [(name: String, typeName: String)] {
        self.properties.keys
            .sorted()
            .reduce([(String, String)]()) { partialResult, key in
                guard
                    let property = self.properties[key],
                    let typeName = property.swiftTypeName else { return partialResult }
                return partialResult + [(key, typeName)]
            }
    }
    
    var swiftInstanceVariables: [String] {
        self.variableNameAndTypes.map { "public let \($0.name): \($0.typeName)?" }
    }
    
    
    var swiftInitializer: String {
        var parameters: [String] = []
        var assignment: [String] = []
        self.variableNameAndTypes.forEach { (name, typeName) in
            parameters.append("\(name): \(typeName)? = nil")
            assignment.append("self.\(name) = \(name)")
        }
        return """
        init(\(parameters.formatted(.list(type: .and, width: .narrow)))) {
                \(assignment.joined(separator: "\n\t\t"))
            }
        """
    }
}

protocol SchemaReferencing {
    var ref: String? { get set }
    
    static func swift(nameForReferenced schema: some SchemaReferencing) -> String?
}

extension SchemaReferencing {
    static func swift(nameForReferenced schema: some SchemaReferencing) -> String? {
        guard let last = schema.ref?.split(separator: "/").last else { return "" }
        return String(last)
    }
}

struct SchemaProperty: Codable, SchemaReferencing {
    public let `type`: String
    public let `format`: String?
    public let items: SchemaPropertyItem?
    public let `enum`: [String]?
    public var ref: String?
    
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

struct SchemaPropertyItem: Codable, SchemaReferencing {
    public var ref: String?
    
    enum CodingKeys: String, CodingKey {
        case ref = "$ref"
    }
}
