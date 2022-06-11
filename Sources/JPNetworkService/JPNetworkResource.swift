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
            
            return urlRequest
        }
        return nil
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
