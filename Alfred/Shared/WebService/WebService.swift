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
		public var logResponses: Bool = false
	}

	public typealias DecodableCompletion<T: Decodable> = (Result<T, Error>) -> Void
	public typealias RequestCompletion<T> = (Result<T, Error>) -> Void

	let session: URLSession
	var subscriptions: Set<AnyCancellable> = []
	public var configuration: WebService.Configuarion = Configuarion()
	public var errorProcessor: ((URLRequest?, Error) -> Void)?

	public init(session: URLSession = .shared) {
		self.session = session
	}

	public func cancelAll() {
		subscriptions.forEach { cancellable in
			cancellable.cancel()
		}
	}

	func request<T: Decodable>(route: APIRouter, decoder: JSONDecoder = AlfredJSONDecoder(), completion: @escaping WebService.DecodableCompletion<T>) -> URLSession.ServicePublisher? {
		guard let request = route.request else {
			completion(.failure(URLError(.badURL)))
			return nil
		}
		return self.request(request: request, decoder: decoder, completion: completion)
	}

	func request(route: APIRouter, completion: @escaping WebService.RequestCompletion<[String: Any]>) -> URLSession.ServicePublisher? {
		guard let request = route.request else {
			completion(.failure(URLError(.badURL)))
			return nil
		}
		return self.request(request: request, completion: completion)
	}

	func request(route: APIRouter, completion: @escaping WebService.RequestCompletion<Bool>) -> URLSession.ServicePublisher? {
		guard let request = route.request else {
			completion(.failure(URLError(.badURL)))
			return nil
		}
		return self.request(request: request, completion: completion)
	}

	func request<T: Decodable>(request: Request, decoder: JSONDecoder = AlfredJSONDecoder(), completion: @escaping WebService.DecodableCompletion<T>) -> URLSession.ServicePublisher? {
		let publisher = session.servicePublisher(for: request)
		publisher.retry(configuration.retryCountForRequest)
			.mapError { [weak self] (failure) -> Error in
				if let processor = self?.errorProcessor {
					processor(request.urlRequest, failure)
				}
				return failure
			}
			.tryMap { [weak self] result -> Data in
				let data = try result.data.ws_validate(result.response).ws_validate()
				if self?.configuration.logResponses == true {
					let string = String(data: data, encoding: .utf8)
					os_log(.info, log: .webservice, "%@", string ?? "")
				}
				return data
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

	func request(request: Request, completion: @escaping WebService.RequestCompletion<[String: Any]>) -> URLSession.ServicePublisher? {
		let publisher = session.servicePublisher(for: request)
		publisher.retry(configuration.retryCountForRequest)
			.mapError { [weak self] (failure) -> Error in
				if let processor = self?.errorProcessor {
					processor(request.urlRequest, failure)
				}
				return failure
			}
			.tryMap { [weak self] result -> Data in
				let data = try result.data.ws_validate(result.response).ws_validate()
				if self?.configuration.logResponses == true {
					let string = String(data: data, encoding: .utf8)
					os_log(.info, log: .webservice, "%@", string ?? "")
				}
				return data
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

	func request(request: Request, completion: @escaping WebService.RequestCompletion<Bool>) -> URLSession.ServicePublisher? {
		let publisher = session.servicePublisher(for: request)
		publisher.retry(configuration.retryCountForRequest)
			.mapError { [weak self] (failure) -> Error in
				if let processor = self?.errorProcessor {
					processor(request.urlRequest, failure)
				}
				return failure
			}
			.tryMap { result -> Data in
				let data = try result.data.ws_validate(result.response)
				return data
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
			}, receiveValue: { _ in
				completion(.success(true))
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
