//
//  CareWebService.swift
//  AlfredCore
//
//  Created by Waqar Malik on 11/23/20.
//

import Combine
import Foundation
import os.log

public protocol Routable {
	var urlRequest: URLRequest? { get }
}

extension OSLog {
	static let webservice = OSLog(subsystem: subsystem, category: "WebService")
}

public final class WebService {
	public struct Configuarion {
		public var retryCountForRequest: Int = 1
		public var retryCountForResource: Int = 3
	}

	public typealias DecodableCompletion<T: Decodable> = (Result<T, Error>) -> Void
	public typealias RequestCompletion<T> = (Result<T, Error>) -> Void

	public enum Header {
		public static let userAgent = "User-Agent"
		public static let contentType = "Content-Type"
		public static let contentLength = "Content-Length"
		public static let contentEncoding = "Content-Encoding"
		public static let accept = "Accept"
		public static let cacheControl = "Cache-Control"
		public static let authorization = "Authorization"
		public static let acceptEncoding = "Accept-Encoding"
		public static let acceptLanguage = "Accept-Language"
		public static let date = "Date"
		public static let CarePlanVectorClockOnly = "CarePlan-Vector-Clock-Only"
		public static let CarePlanPrefer = "Careplan-Prefer"
	}

	public enum ContentType {
		public static let formEncoded = "application/x-www-form-urlencoded"
		public static let json = "application/json"
		public static let xml = "application/xml"
		public static let textPlain = "text/plain"
		public static let html = "text/html"
		public static let css = "text/css"
		public static let octet = "application/octet-stream"
		public static let jpeg = "image/jpeg"
		public static let png = "image/png"
		public static let gif = "image/gif"
		public static let svg = "image/svg+xml"
	}

	let session: URLSession
	var subscriptions: Set<AnyCancellable> = []
	public var configuration: WebService.Configuarion = Configuarion()

	public init(session: URLSession) {
		self.session = session
	}

	public func cancelAll() {
		subscriptions.forEach { cancellable in
			cancellable.cancel()
		}
	}

	public func getCarePlan(vectorClock: Bool = false, valueSpaceSample: Bool = false, completion: @escaping WebService.RequestCompletion<[String: Any]>) {
		// CarePlan-Vector-Clock-Only: true
		// Careplan-Prefer: return=ValueSpaceSample
		// request(route: .getCarePlan(vectorClock: vectorClock, valueSpaceSample: valueSpaceSample), completion: completion)
	}

	@discardableResult
	func request<T: Decodable>(route: Routable, decoder: JSONDecoder = AlfredJSONDecoder(), completion: @escaping WebService.DecodableCompletion<T>) -> URLSession.DataTaskPublisher? {
		guard let request = route.urlRequest else {
			completion(.failure(URLError(.badURL)))
			return nil
		}
		let publisher = session.dataTaskPublisher(for: request)
		publisher
			.retry(configuration.retryCountForRequest)
			.tryMap { result -> Data in
				try result.data.cws_validate(result.response).cws_validate()
			}
			.decode(type: T.self, decoder: decoder)
			.subscribe(on: DispatchQueue.global(qos: .background))
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { receiveCompletion in
				switch receiveCompletion {
				case .failure(let error):
					completion(.failure(error))
					os_log("%@", log: .webservice, type: .error, error.localizedDescription)
				case .finished:
					os_log(.info, log: .webservice, "Finished Dowloading")
				}
			}, receiveValue: { value in
				completion(.success(value))
			}).store(in: &subscriptions)
		return publisher
	}

	@discardableResult
	func request(route: Routable, completion: @escaping WebService.RequestCompletion<[String: Any]>) -> URLSession.DataTaskPublisher? {
		guard let request = route.urlRequest else {
			completion(.failure(URLError(.badURL)))
			return nil
		}

		let publisher = session.dataTaskPublisher(for: request)
		publisher
			.retry(configuration.retryCountForRequest)
			.tryMap { element -> Data in
				try element.data.cws_validate(element.response).cws_validate()
			}
			.tryMap { (data) -> [String: Any] in
				guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
					throw URLError(.cannotDecodeContentData)
				}
				return jsonObject
			}
			.subscribe(on: DispatchQueue.global(qos: .background))
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { receiveCompletion in
				switch receiveCompletion {
				case .failure(let error):
					os_log("%@", log: .webservice, type: .error, error.localizedDescription)
					completion(.failure(error))
				case .finished:
					os_log(.info, log: .webservice, "Finished Dowloading")
				}
			}, receiveValue: { value in
				completion(.success(value))
			}).store(in: &subscriptions)
		return publisher
	}
}
