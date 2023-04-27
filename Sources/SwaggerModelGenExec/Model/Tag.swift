public struct Tag: Decodable, CustomStringConvertible {
    public let name: String
    let descr: String
    
    public var description: String { descr }
    
    enum CodingKeys: String, CodingKey {
        case name
        case descr = "description"
    }
}
