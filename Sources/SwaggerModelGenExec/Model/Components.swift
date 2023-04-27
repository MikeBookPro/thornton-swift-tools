public struct Components: Decodable {
    public let schemas: [String: Schema]
    
    // TODO: Move this out of model Codable and into own `SwiftBuilder`
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
