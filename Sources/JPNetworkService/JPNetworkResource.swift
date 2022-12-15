//
//  JPNetworkResource.swift
//  
//
//  Created by Sasikumar JP on 11/06/22.
//

import Foundation

public protocol JPNetworkResource {
    var baseURL: URL { get }
    var endPoint: String { get }
    var method: HttpMethod { get }
    var headers: [String: String] { get}
    var params: [String:Any] { get }
    var bodyParams: [String:Any] { get }
    var body: Data? { get }
    var paramsEncoding: ParameterEncoding { get }
    var authType: AuthType { get }
    var urlRequest: URLRequest? { get }
}

public extension JPNetworkResource {

    var headers: [String:String] {
        return [:]
    }
    
    var params: [String:Any] {
        return [:]
    }
    
    var body: Data? {
        return nil
    }
    
    var urlRequest: URLRequest? {
        let urlString = (baseURL.absoluteString + endPoint).trimmingCharacters(in: .whitespacesAndNewlines)
        var urlComponents = URLComponents(string: urlString)
        if method == .get {
            var queryItems: [URLQueryItem] = []
            for (key, value) in params {
                if let value = value as? String {
                    let queryItem = URLQueryItem(name: key, value: value)
                    queryItems.append(queryItem)
                }
            }
            
            if queryItems.count > 0 {
                urlComponents?.queryItems = queryItems
            }
        }
        
        if let url = urlComponents?.url {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.name
            if headers.count > 0 {
                urlRequest.allHTTPHeaderFields = headers
            }
            
            if method == .post || method == .delete || method == .put {
                
            }
            return urlRequest
        }
        return nil
    }
    
    func encodedParameters() -> Data? {
        switch paramsEncoding {
            case .url:
                var components:[(String, String)] = []
                for key in params.keys.sorted(by: <) {
                    if let value = params[key] as? String {
                        components.append((escape(key),escape(value)))
                    }
                }
                return components.map { "\($0)=\($1)" }.joined(separator: "&").data(using: String.Encoding.utf8)
            case .json:
                do {
                    if params.count > 0 {
                        let jsonData = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.fragmentsAllowed)
                        return jsonData
                    } else if let jsonData = body {
                        return jsonData
                    }
                } catch {
                    print("error \(error)")
                }
            case  let .multipart(boundary: boundaryString):
                do {
                    let jsonData = try createBody(with: params, boundaryString: boundaryString)
                    return jsonData
                } catch {
                    print("Multipart error:\(error)")
                }
            default:
                break
        }
        return nil
    }
    
    func encodedBodyParameters() -> Data? {
        switch paramsEncoding {
            case .url:
                var components:[(String, String)] = []
                for key in bodyParams.keys.sorted(by: <) {
                    if let value = bodyParams[key] as? String {
                        components.append((escape(key),escape(value)))
                    }
                }
                return components.map { "\($0)=\($1)" }.joined(separator: "&").data(using: String.Encoding.utf8)
            case .json:
                do {
                    if bodyParams.count > 0 {
                        let jsonData = try JSONSerialization.data(withJSONObject: bodyParams, options: JSONSerialization.WritingOptions.fragmentsAllowed)
                        return jsonData
                    } else if let jsonData = body {
                        return jsonData
                    }
                } catch {
                    print("error \(error)")
                }
            case  let .multipart(boundary: boundaryString):
                do {
                    let jsonData = try createBody(with: params, boundaryString: boundaryString)
                    return jsonData
                } catch {
                    print("Multipart error:\(error)")
                }
            default:
                break
        }
        return nil
    }
    
    
    private func createBody(with parameters: [String: Any], boundaryString: String) throws -> Data {
        var body = Data()
        for (key, rawValue) in parameters {
            if !body.isEmpty {
                body.append("\r\n".data(using: .utf8)!)
            }
            body.append("--\(boundaryString)\r\n".data(using: .utf8)!)
            
            guard
                key.canBeConverted(to: .utf8),
                let disposition = "Content-Disposition: form-data; name=\"\(key)\"\r\n".data(using: .utf8) else {
                throw MultipartFormDataEncodingError.name(key)
            }
            body.append(disposition)
            
            body.append("\r\n".data(using: .utf8)!)
            
            if let strValue = rawValue as? String {
                guard let value = strValue.data(using: .utf8) else {
                    throw MultipartFormDataEncodingError.value(strValue, name: key)
                }
                body.append(value)
            }
        }
        
        body.append("\r\n--\(boundaryString)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        let escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        return escaped
    }

}

public enum HttpMethod {
    case get, post, delete, put, head
    
    public var name: String {
        switch self {
            case .get: return "GET"
            case .post: return "POST"
            case .delete: return "DELETE"
            case .put: return "PUT"
            case .head: return "HEAD"
        }
    }
}

public enum AuthType: Equatable {
    
    case basic(userName: String, password: String), token(token: String), none
    
    public static func ==(lhs: AuthType, rhs: AuthType) -> Bool {
        switch (lhs, rhs) {
            case (.basic, .basic): return true
            case (.none, .none): return true
            case (.token, .token): return true
            default:
                return false
        }
    }
}

public enum ParameterEncoding {
    case url, json, form, none, multipart(boundary: String)
}

enum MultipartFormDataEncodingError: Error {
    case characterSetName
    case name(String)
    case value(String, name: String)
}
