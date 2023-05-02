public struct EndpointOperationContent: Decodable {
    public let description: String
    /// EncodingType
    public let content: EndpointOperationContentEncoding?
}

public struct EndpointOperationContentEncoding: Decodable {
    public let any: EndpointOperationContentEncodedSchema?
    public let json: EndpointOperationContentEncodedSchema?
    public let xml: EndpointOperationContentEncodedSchema?
    public let plainText: EndpointOperationContentEncodedSchema?
    public let htmlText: EndpointOperationContentEncodedSchema?
    public let octetStream: EndpointOperationContentEncodedSchema?
    public let formData: EndpointOperationContentEncodedSchema?
    public let formURL: EndpointOperationContentEncodedSchema?
    
    enum CodingKeys: String, CodingKey {
        case any = "*/*"
        case json = "application/json"
        case xml = "application/xml"
        case plainText = "text/plain"
        case htmlText = "text/html"
        case octetStream = "application/octet-stream"
        case formData = "multipart/form-data"
        case formURL = "application/x-www-form-urlencoded"
    }
}

public struct EndpointOperationContentEncodedSchema: Decodable {
    public let schema: SchemaProperty
}
