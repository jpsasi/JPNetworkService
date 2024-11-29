import Foundation

protocol JPWebService {
  func load(networkResource: JPNetworkResource) async throws
    -> JPNetworkResponse
}

public class JPNetworkService: JPWebService {
  let urlSession: URLSession

  public init(urlSession: URLSession) {
    self.urlSession = urlSession
  }

  public func load(networkResource: JPNetworkResource) async throws
    -> JPNetworkResponse
  {
    guard let urlRequest = networkResource.urlRequest else {
      throw JPNetworkError.invalidUrl
    }

    let (data, response) = try await urlSession.data(for: urlRequest)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw JPNetworkError.invalidResponse
    }

    let networkResponse = JPNetworkResponse(
      statusCode: httpResponse.statusCode,
      data: data,
      urlRequest: urlRequest,
      httpResponse: httpResponse)

    switch networkResponse.statusCode {
    case 200..<300: return networkResponse
    case 400..<500: throw JPNetworkError.clientError(networkResponse)
    case 500..<600: throw JPNetworkError.serverError(networkResponse)
    default: throw JPNetworkError.unknown
    }
  }
}
