extension SwaggerModel {
    
    enum NetworkModel {
        static func string(for swaggerModel: SwaggerModel) -> String {
            let structCode = SwaggerModel.SchemaStruct.string(for: swaggerModel.components.schemas)
            let enumCode = SwaggerModel.SchemaEnum.string(for: swaggerModel.components.schemas)
            
            return """
            public enum NetworkModel {
                \([structCode, enumCode].joined(separator: "\n"))
            }
            """
            
        }
    }
    
    enum NetworkAPI {
        static func string(for swaggerModel: SwaggerModel) -> String {
            let urlHost = swaggerModel.servers.first?.urlString ?? "{- NetworkAPI.servers.first?.urlString -}"
            let networkCode = swaggerModel.paths
                .compactMap({ path in
                    let (urlPath, endpoint) = path
                    return EndpointNetworkRequest.string(for: endpoint)
                        .replacing(templates: [
                            (target: "<URL_PATH>", replacement: urlPath),
                            (target: "<URL_HOST>", replacement: urlHost)
                        ])
                })
                .joined(separator: "\n\n")
            
            
            
            return """
            public enum NetworkAPI {
                \(networkCode)
            }
            """
            
        }
    }
    
    enum EndpointNetworkRequest {
        static func string(for endpoint: Endpoint) -> String {
            Self.components(for: endpoint)
                .compactMap { component in
                    let (requestTypeName, operationPath) = component
                    guard let endpointOperation = endpoint[keyPath: operationPath] else { return nil }
                    return SwaggerModel.EndpointOperationNetworkRequest.string(for: endpointOperation)
                        .replacing(templates: [
                            (target: "<HTTP_REQUEST_TYPE>", replacement: requestTypeName),
                        ])
                }
                .joined(separator: "\n\t")
        }
        
        private static func components(for endpoint: Endpoint) -> [(requestTypeName: String, endpointOperationPath: KeyPath<Endpoint, EndpointOperation?>)] {
            var result = [(requestTypeName: String, endpointOperationPath: KeyPath<Endpoint, EndpointOperation?>)]()
            if endpoint.get != nil { result.append((requestTypeName: "get", endpointOperationPath: \.get )) }
            if endpoint.post != nil { result.append((requestTypeName: "post", endpointOperationPath: \.post )) }
            if endpoint.put != nil { result.append((requestTypeName: "put", endpointOperationPath: \.put )) }
            if endpoint.delete != nil { result.append((requestTypeName: "delete", endpointOperationPath: \.delete )) }
            if endpoint.head != nil { result.append((requestTypeName: "head", endpointOperationPath: \.head )) }
            if endpoint.connect != nil { result.append((requestTypeName: "connect", endpointOperationPath: \.connect )) }
            if endpoint.trace != nil { result.append((requestTypeName: "trace", endpointOperationPath: \.trace )) }
            if endpoint.patch != nil { result.append((requestTypeName: "patch", endpointOperationPath: \.patch )) }
            return result.isEmpty ? [(requestTypeName: "{- HTTPRequestType -}", endpointOperationPath: \.connect )] : result
        }
    }
    
    
    
    enum EndpointOperationNetworkRequest {
        
        static func string(for endpointOperation: EndpointOperation) -> String {
            let operationID = endpointOperation.operationID
            let parameterComponents = endpointOperation.parameters
                .compactMap({ SwaggerModel.QueryParameter.components(for: $0, shouldProvideInternalName: true) })
            let queryItems: String = parameterComponents
                .map({ "URLQueryItem(name: \"\($0.name)\", value: \($0.invokedName))" })
                .joined(separator: ",\n\t")
            let urlQueryInvocationParameters: String = parameterComponents
                .map({ "\($0.name): \($0.internalName)" })
                .joined(separator: ", ")
            
            let urlQueryParameters: String = endpointOperation.parameters
                .compactMap({ SwaggerModel.QueryParameter.string(for: $0, shouldProvideInternalName: true) })
                .joined(separator: ", ")
            let operationSummary = (endpointOperation.summary == nil) ? "" : "/// \(endpointOperation.summary ?? "")"
            let operationDescription = (endpointOperation.description == nil) ? "" : """
            ///
            \t/// \(endpointOperation.description ?? "")
            """
            let responseTypeName = SwaggerModel.EndpointOperationNetworkResponse.string(for: endpointOperation)
            
            return """
            
                \(operationSummary)
                \(operationDescription)
                public static func \(operationID)(\(urlQueryParameters)) async throws -> \(responseTypeName)? {
                    guard let url = \(operationID)URL(\(urlQueryInvocationParameters)) else { return nil }
                    var request = URLRequest(url: url)
                    request.httpMethod = \"<HTTP_REQUEST_TYPE>\"
                    let (data, response) = try await URLSession.shared.data(for: request)
                    
                    guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
                    return try JSONDecoder().decode(\(responseTypeName).self, from: data)
                }

                private static func \(operationID)URL(\(urlQueryParameters)) -> URL? {
                    var urlComponents = URLComponents()
                    urlComponents.path = \"<URL_PATH>\"
                    urlComponents.queryItems = [
                        \(queryItems)
                    ]
                    return urlComponents.url(relativeTo: URL(string: \"<URL_HOST>\"))
                }
            
            """
        }
    }
    
    enum EndpointOperationNetworkResponse {
        static func string(for endpointOperation: EndpointOperation) -> String {
            guard let response = endpointOperation.responses["200"], let content = response.content else { return "{- EndpointOperationNetworkResponse -}" }
            return Self.string(for: content)
        }
        
        private static func string(for encodedContent: EndpointOperationContentEncoding) -> String {
//            return "\(encodedContent.json?.schema)"
            Self.components(for: encodedContent)
                .filter({ (encodingTypeName, encodedResultPath) in
                    ResponseContentEncodingType(rawValue: encodingTypeName) == .json
                })
                .compactMap {
                    let (_, encodedResultPath) = $0 // TODO: Use encodingTypeName to accept more than content/json
                    guard let encodedResult = encodedContent[keyPath: encodedResultPath] else { return nil }
                    return Self.string(for: encodedResult)
                }
                .first ?? "{- EndpointNetworkResponse.string(for: EndpointOperationContentEncoding) -}"
        }
        
        private static func string(for responseSchema: SchemaProperty) -> String {
            let referenceSchema: SchemaReferencing? = (responseSchema.ref != nil) ? responseSchema : responseSchema.items
            if let reference = referenceSchema {
                let referenceTypeName = "NetworkModel.\(SchemaReferencingTypeName.string(for: reference))"
                return (responseSchema.type == "array") ? "[\(referenceTypeName)]" : referenceTypeName
            }
            if let propertyType = responseSchema.type {  return SimplePropertyTypeName.string(for: propertyType, formatType: responseSchema.format) }
            return "{- EndpointOperationNetworkResponse test-}"
        }
        
        private static func components(for contentEncoding: EndpointOperationContentEncoding) -> [(encodingTypeName: String, encodedResultPath: KeyPath<EndpointOperationContentEncoding, SchemaProperty?>)] {
            var result = [(encodingTypeName: String, encodedResultPath: KeyPath<EndpointOperationContentEncoding, SchemaProperty?>)]()
            if contentEncoding.any != nil { result.append((ResponseContentEncodingType.any.rawValue, \.any?.schema )) }
            if contentEncoding.json != nil { result.append((ResponseContentEncodingType.json.rawValue, \.json?.schema )) }
            if contentEncoding.xml != nil { result.append((ResponseContentEncodingType.xml.rawValue, \.xml?.schema )) }
            if contentEncoding.plainText != nil { result.append((ResponseContentEncodingType.plainText.rawValue, \.plainText?.schema )) }
            if contentEncoding.htmlText != nil { result.append((ResponseContentEncodingType.htmlText.rawValue, \.htmlText?.schema )) }
            if contentEncoding.octetStream != nil { result.append((ResponseContentEncodingType.octetStream.rawValue, \.octetStream?.schema )) }
            if contentEncoding.formData != nil { result.append((ResponseContentEncodingType.formData.rawValue, \.formData?.schema )) }
            if contentEncoding.formURL != nil { result.append((ResponseContentEncodingType.formURL.rawValue, \.formURL?.schema )) }
            return result.isEmpty ? [(encodingTypeName: "{- EndpointOperationResponseTypeName -}", encodedResultPath: \.any?.schema )] : result
        }
    }
    
    enum SchemaStruct {
        static func string(for schemas: [String: Schema]) -> String {
            return schemas.reduce(into: "") { (partialResult, input) in
                let (structName, schema) = input
                guard schema.type == "object" else { return }
                let components = SwaggerModel.SchemaProperties.components(for: schema)
                let properties = components.reduce(into: "") { (partialResult, input) in
                    partialResult.append("public let \(input.name): \(input.typeName)?\n\t\t")
                }
                
                let parameters = components.reduce(into: "") { (partialResult, input) in
                    partialResult.append("\(partialResult.isEmpty ? "" : ", ")\(input.name): \(input.typeName)? = nil")
                }
                
                let assignment = components.reduce(into: "") { (partialResult, input) in
                    partialResult.append("self.\(input.name) = \(input.name)\n\t\t\t")
                }
                
                let structCode = """
                
                    public struct \(structName): Codable {
                        \(properties)
                        public init(\(parameters)) {
                            \(assignment)
                        }
                    }
                
                """
                partialResult.append(structCode)
            }
        }
    }
    
    enum SchemaEnum {
        static func string(for schemas: [String: Schema]) -> String {
            return schemas.reduce(into: "") { (partialResult, input) in
                let (enumName, schema) = input
                guard schema.type == "string", let enumCases = schema.enumCases else { return }
                
                let cases = enumCases.reduce(into: "") { (partialResult, input) in
                    partialResult.append("case \(input)\n\t\t")
                }
                
                let code = """
                    public enum \(enumName): String {
                        \(cases)
                    }
                """
                partialResult.append(code)
            }
        }
    }
    
    enum SchemaProperties {
        static func components(for schema: Schema) -> [(name: String, typeName: String)] {
            guard let properties = schema.properties else { return [] }
            return properties.keys
                .sorted(by: String.alphabeticalPrefixThenDigitOrder)
                .reduce([(name: String, typeName: String)]()) { partialResult, propertyName in
                    guard let property = properties[propertyName] else { return partialResult }
                    return partialResult + [(name: propertyName, typeName: SwaggerModel.SchemaPropertyTypeName.string(for: property))]
                }
        }
    }
    
    enum QueryParameter {
        static func string(for parameter: EndpointOperationParameter, shouldProvideInternalName hasInternalName: Bool = false) -> String? {
            guard let components = components(for: parameter, shouldProvideInternalName: hasInternalName) else { return nil }
            return "\(components.name) \(components.internalName): \(components.typeName)"
        }
        
        static func components(for parameter: EndpointOperationParameter, shouldProvideInternalName hasInternalName: Bool = false) -> (name: String, internalName: String, typeName: String, invokedName: String)? {
            guard parameter.parameterType == .query, let schema = parameter.schema else { return nil }
            let parameterTypeName = "\(SchemaPropertyTypeName.string(for: schema))\(parameter.isRequired ? "" : "?")"
            let internalParameterName = (hasInternalName) ? "\(SchemaPropertyInternalParameterName.string(for: schema))" : ""
            let invokedName = (hasInternalName) ? QueryParameterSchemaInvokedName.string(for: schema) ?? internalParameterName : internalParameterName
            return (name: parameter.name, internalName: internalParameterName, typeName: parameterTypeName, invokedName: invokedName)
        }
    }
    
    enum QueryParameterSchemaInvokedName {
        private static let valueTypeNames: Set<String> = .init(["boolean", "integer", "number"])
        private static func isValueTypeName(_ value: String) -> Bool { valueTypeNames.contains(value) }
        
        static func string(for schemaProperty: SchemaProperty) -> String? {
            let reference: SchemaReferencing? = (schemaProperty.ref != nil) ? schemaProperty : schemaProperty.items
            if let reference { return SchemaReferencingTypeName.string(for: reference).lowercasedFirstCharacter + ".rawValue" }
            if let propertyType = schemaProperty.type, isValueTypeName(propertyType) { return "\"\\(value)\"" }
            return "{- QueryParameterSchemaInvokedName -}"
        }
    }
    
    enum SchemaPropertyTypeName {
        static func string(for schemaProperty: SchemaProperty) -> String {
            let reference: SchemaReferencing? = (schemaProperty.ref != nil) ? schemaProperty : schemaProperty.items
            if let reference {
                let referenceTypeName = "NetworkModel.\(SchemaReferencingTypeName.string(for: reference))"
                return (schemaProperty.type == "array") ? "[\(referenceTypeName)]" : referenceTypeName
            }
            
            if let propertyType = schemaProperty.type {  return SimplePropertyTypeName.string(for: propertyType, formatType: schemaProperty.format) }
            return "{- SchemaPropertyTypeName -}"
        }
    }
    
    enum SchemaReferencingTypeName {
        static func string(for schema: some SchemaReferencing) -> String {
            guard
                let ref = schema.ref,
                let lastPath = ref.split(separator: "/").last,
                let last = lastPath.split(separator: ".").last
            else { return "{- SchemaReferencingTypeName -}" }
            return String(last)
        }
    }
    
    enum SimplePropertyTypeName {
        static func string(for propertyType: String, formatType: String? = nil) -> String {
            switch (propertyType, formatType) {
                case ("boolean", _): return String(describing: Bool.self)
                case ("string", _): return String(describing: String.self)
                case ("integer", "int32"): return String(describing: Int32.self)
                case ("integer", "int64"): return String(describing: Int64.self)
                case ("number", "float"): return String(describing: Float.self)
                case ("number", "double"): return String(describing: Double.self)
                default: return "{- SimplePropertyTypeName -}"
            }
        }
    }
    
    enum SchemaPropertyInternalParameterName {
        private static let simpleTypeNames: Set<String> = .init(["boolean", "string", "integer", "number"])
        
        private static func isSimplePropertyTypeName(_ value: String) -> Bool {
            simpleTypeNames.contains(value)
        }
        
        
        static func string(for schemaProperty: SchemaProperty) -> String {
            let reference: SchemaReferencing? = (schemaProperty.ref != nil) ? schemaProperty : schemaProperty.items
            if let reference { return SchemaReferencingTypeName.string(for: reference).lowercasedFirstCharacter }
            if let propertyType = schemaProperty.type, isSimplePropertyTypeName(propertyType) { return "value" }
            return "{- SchemaPropertyInternalParameterName -}"
        }
        
        
    }
    
    
    enum ResponseContentEncodingType: String {
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
