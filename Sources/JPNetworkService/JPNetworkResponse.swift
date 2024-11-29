//
//  JPNetworkResponse.swift
//
//
//  Created by Sasikumar JP on 11/06/22.
//

import Foundation

public class JPNetworkResponse {
  public let statusCode: Int
  public let data: Data?
  public let urlRequest: URLRequest?
  public let httpResponse: HTTPURLResponse?

  public init(
    statusCode: Int, data: Data?, urlRequest: URLRequest?,
    httpResponse: HTTPURLResponse?
  ) {
    self.statusCode = statusCode
    self.data = data
    self.urlRequest = urlRequest
    self.httpResponse = httpResponse
  }
}

extension JPNetworkResponse: CustomStringConvertible {
  public var description: String {
    guard let data, let dataString = String(data: data, encoding: .utf8) else {
      return "\(statusCode)"
    }
    return "\(statusCode):\(dataString)"
  }
}

extension JPNetworkResponse: CustomDebugStringConvertible {
  public var debugDescription: String {
    guard let data, let dataString = String(data: data, encoding: .utf8) else {
      return "\(statusCode)"
    }
    return "\(statusCode):\(dataString)"
  }
}

