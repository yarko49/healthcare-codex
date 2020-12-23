//
//  DataRequest+Processing.swift
//  alfred-ios
//

import Alamofire
import CodableAlamofire
import Foundation

public extension DataRequest {
	@discardableResult
	func getResponse(queue: DispatchQueue = .main, completionHandler: @escaping (AFDataResponse<Data?>) -> Void) -> Self {
		var url: String? {
			request?.url?.absoluteString
		}
		return response(queue: queue) { dataResponse in
			if let error = dataResponse.error {
				RequestPostProcessor.processResponse(dataResponse.data, error: error, url: url)
			}
			completionHandler(dataResponse)
		}
	}

	@discardableResult
	func getResponseDecodableObject<T: Decodable>(queue: DispatchQueue = .main, keyPath: String? = nil, decoder: JSONDecoder = JSONDecoder(), completionHandler: @escaping (AFDataResponse<T>) -> Void) -> Self {
		var url: String? {
			request?.url?.absoluteString
		}
		return responseDecodableObject(queue: queue, keyPath: keyPath, decoder: decoder) { (dataResponse: AFDataResponse<T>) in
			if let error = dataResponse.error {
				RequestPostProcessor.processResponse(dataResponse.data, error: error, url: url)
			}
			completionHandler(dataResponse)
		}
	}
}
