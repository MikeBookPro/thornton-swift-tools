import Foundation

public struct EndpointOperation: Decodable {
    public let tags: [String]
    public let summary: String?
    public let description: String?
    public let operationID: String
    public let parameters: [EndpointOperationParameter]
    public let requestBody: EndpointOperationContent?
    
    /// String here is the HTTP Response code, ex: "200"
    public let responses: [String: EndpointOperationContent]
    
    enum CodingKeys: String, CodingKey {
        case tags
        case summary
        case description
        case operationID = "operationId"
        case parameters
        case requestBody
        case responses
    }
}
