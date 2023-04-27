//import Foundation

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
