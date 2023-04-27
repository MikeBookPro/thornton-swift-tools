public struct EndpointOperationParameter: Decodable {
    public let name: String
    public let parameterType: ParameterType
    public let description: String?
    public let isRequired: Bool
    public let allowEmptyValue: Bool?
    public let schema: SchemaProperty?
//    public let style // TODO: Handle this later
    
    enum CodingKeys: String, CodingKey {
        case name
        case parameterType = "in"
        case description
        case isRequired = "required"
        case allowEmptyValue
        case schema
//        case style
    }
}
