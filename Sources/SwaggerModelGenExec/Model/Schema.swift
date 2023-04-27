public struct Schema: Codable {
    public let `type`: String
    public let properties: [String: SchemaProperty]
    
    // TODO: Move this out of model Codable and into own `SwiftBuilder`
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
