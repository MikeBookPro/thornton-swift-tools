public struct EndpointOperationContent: Decodable {
    public let description: String
    public let content: [String: SchemaProperty]? // EncodingType
}
