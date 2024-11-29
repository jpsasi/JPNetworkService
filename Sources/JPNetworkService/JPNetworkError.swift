//
//  JPNetworkError.swift
//
//
//  Created by Sasikumar JP on 11/06/22.
//

import Foundation

public enum JPNetworkError: Error {
  case duplicateRequest
  case invalidUrl
  case invalidResponse
  case clientError(JPNetworkResponse)
  case serverError(JPNetworkResponse)
  case error(Error)
  case unknown

  public var errorCode: Int? {
    switch self {
    case .clientError(let networkResponse):
      return networkResponse.statusCode
    case .serverError(let networkResponse):
      return networkResponse.statusCode
    default:
      return nil
    }
  }
}
