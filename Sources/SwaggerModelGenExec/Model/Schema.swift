public struct Schema: Decodable {
    public let `type`: String
    public let properties: [String: SchemaProperty]?
    public let enumCases: [String]?
    
    enum CodingKeys: String, CodingKey {
        case `type`
        case properties
        case enumCases = "enum"
    }
    
    // TODO: Move this out of model Codable and into own `SwiftBuilder`
    private var variableNameAndTypes: [(name: String, typeName: String)] {
        guard let properties else { return [] }
        return properties.keys
            .sorted()
            .reduce([(String, String)]()) { partialResult, key in
                guard let property = properties[key] else { return partialResult }
                return partialResult + [(key, SwaggerModel.SchemaPropertyTypeName.string(for: property))]
            }
    }
    
    // TODO: Move this out of model Codable and into own `SwiftBuilder`
    public var swiftInstanceVariables: [String] {
        self.variableNameAndTypes.map { "public let \($0.name): \($0.typeName)?" }
    }
    
    
    // TODO: Move this out of model Codable and into own `SwiftBuilder`
    public var swiftInitializer: String {
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
