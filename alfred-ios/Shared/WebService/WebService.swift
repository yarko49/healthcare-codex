//
//  CareWebService.swift
//  AlfredCore
//
//  Created by Waqar Malik on 11/23/20.
//

import Combine
import Foundation
import os.log

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

	let session: URLSession
	var subscriptions: Set<AnyCancellable> = []
	public var configuration: WebService.Configuarion = Configuarion()

	public init(session: URLSession = .shared) {
		self.session = session
	}

	public func cancelAll() {
		subscriptions.forEach { cancellable in
			cancellable.cancel()
		}
	}

	@discardableResult
	func request<T: Decodable>(route: APIRouter, decoder: JSONDecoder = AlfredJSONDecoder(), completion: @escaping WebService.DecodableCompletion<T>) -> URLSession.DataTaskPublisher? {
		guard let request = route.urlRequest else {
			completion(.failure(URLError(.badURL)))
			return nil
		}
		let publisher = session.dataTaskPublisher(for: request)
		publisher
			.retry(configuration.retryCountForRequest)
			.tryMap { result -> Data in
				try result.data.ws_validate(result.response).ws_validate()
			}
			.decode(type: T.self, decoder: decoder)
			.subscribe(on: DispatchQueue.global(qos: .background))
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { receiveCompletion in
				switch receiveCompletion {
				case .failure(let error):
					os_log(.error, log: .webservice, "%@", error.localizedDescription)
					completion(.failure(error))
				case .finished:
					os_log(.info, log: .webservice, "Finished Dowloading")
				}
			}, receiveValue: { value in
				completion(.success(value))
			}).store(in: &subscriptions)
		return publisher
	}

	@discardableResult
	func request(route: APIRouter, completion: @escaping WebService.RequestCompletion<[String: Any]>) -> URLSession.DataTaskPublisher? {
		guard let request = route.urlRequest else {
			completion(.failure(URLError(.badURL)))
			return nil
		}
		let publisher = session.dataTaskPublisher(for: request)
		publisher
			.retry(configuration.retryCountForRequest)
			.tryMap { element -> Data in
				try element.data.ws_validate(element.response).ws_validate()
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
					os_log(.error, log: .webservice, "%@", error.localizedDescription)
					completion(.failure(error))
				case .finished:
					os_log(.info, log: .webservice, "Finished Dowloading")
				}
			}, receiveValue: { value in
				completion(.success(value))
			}).store(in: &subscriptions)
		return publisher
	}

	@discardableResult
	func request<T: Decodable>(request: Request, decoder: JSONDecoder = AlfredJSONDecoder(), completion: @escaping WebService.DecodableCompletion<T>) -> URLSession.ServicePublisher? {
		let publisher = session.servicePublisher(for: request)
		publisher
			.retry(configuration.retryCountForRequest)
			.tryMap { result -> Data in
				try result.data.ws_validate(result.response).ws_validate()
			}
			.decode(type: T.self, decoder: decoder)
			.subscribe(on: DispatchQueue.global(qos: .background))
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { receiveCompletion in
				switch receiveCompletion {
				case .failure(let error):
					os_log(.error, log: .webservice, "%@", error.localizedDescription)
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

public extension WebService {
	func request(_ method: Request.Method, url: URL) -> URLSession.ServicePublisher {
		servicePublisher(request: Request(method, url: url))
	}

	func servicePublisher(request: Request) -> URLSession.ServicePublisher {
		URLSession.ServicePublisher(request: request, session: session)
	}
}
