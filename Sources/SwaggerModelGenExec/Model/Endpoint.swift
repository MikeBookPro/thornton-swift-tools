struct Endpoint: Decodable {
    public let get: EndpointOperation?
    public let head: EndpointOperation?
    public let post: EndpointOperation?
    public let put: EndpointOperation?
    public let delete: EndpointOperation?
    public let connect: EndpointOperation?
    public let trace: EndpointOperation?
    public let patch: EndpointOperation?
}
