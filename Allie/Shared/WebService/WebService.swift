//
//  WebService.swift
//  Allie
//
//  Created by Waqar Malik on 11/23/20.
//

import Combine
import Foundation

public final class WebService {
	public struct Configuarion {
		public var retryCountForRequest: Int = 1
		public var retryCountForResource: Int = 3
		public var logResponses: Bool = false
	}

	public typealias DecodableCompletion<T: Decodable> = (Result<T, Error>) -> Void
	public typealias RequestCompletion<T> = (Result<T, Error>) -> Void

	let session: URLSession
	public var configuration: WebService.Configuarion = Configuarion()
	public var errorProcessor: ((URLRequest?, Error) -> Void)?
	public var responseHandler: ((HTTPURLResponse) throws -> Void)?

	public init(session: URLSession = .shared) {
		self.session = session
	}

	func request<T: Decodable>(route: APIRouter, decoder: JSONDecoder = CHJSONDecoder()) -> AnyPublisher<T, Error> {
		guard let request = route.request else {
			return Fail(error: URLError(.badURL))
				.eraseToAnyPublisher()
		}
		return decodable(request: request, decoder: decoder)
	}

	func serializable(route: APIRouter) -> AnyPublisher<Any, Error> {
		guard let request = route.request else {
			return Fail(error: URLError(.badURL))
				.eraseToAnyPublisher()
		}
		return serializable(request: request)
	}

	func simple(route: APIRouter) -> AnyPublisher<Bool, Error> {
		guard let request = route.request else {
			return Fail<Bool, Error>(error: URLError(.badURL))
				.eraseToAnyPublisher()
		}
		return simple(request: request)
	}

	func data(url: URL) -> AnyPublisher<Data, Error> {
		session.dataTaskPublisher(for: url)
			.tryMap { [weak self] result in
				let data = try result.data.ws_validate(result.response).ws_validate()
				if self?.configuration.logResponses == true {
					let string = String(data: data, encoding: .utf8)
					ALog.info("\(string ?? "")")
				}
				return data
			}
			.subscribe(on: DispatchQueue.global(qos: .background))
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	func decodable<T: Decodable>(request: Request, decoder: JSONDecoder = CHJSONDecoder()) -> AnyPublisher<T, Error> {
		session.servicePublisher(for: request)
			.retry(configuration.retryCountForRequest)
			.mapError { [weak self] failure -> Error in
				if let processor = self?.errorProcessor {
					processor(request.urlRequest, failure)
				}
				return failure
			}
			.tryMap { [weak self] response -> (data: Data, response: URLResponse) in
				guard let httpResponse = response.response as? HTTPURLResponse else {
					throw URLError(.badServerResponse)
				}

				// We only want to re auth and other wise just pass the error down
				if let handler = self?.responseHandler, httpResponse.statusCode == 401 {
					try handler(httpResponse)
				}
				return response
			}
			.tryMap { [weak self] result -> Data in
				let data = try result.data.ws_validate(result.response).ws_validate()
				if self?.configuration.logResponses == true {
					let string = String(data: data, encoding: .utf8)
					ALog.info("\(string ?? "")")
				}
				return data
			}
			.decode(type: T.self, decoder: decoder)
			.subscribe(on: DispatchQueue.global(qos: .background))
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	func serializable(request: Request) -> AnyPublisher<Any, Error> {
		session.servicePublisher(for: request)
			.retry(configuration.retryCountForRequest)
			.mapError { [weak self] failure -> Error in
				if let processor = self?.errorProcessor {
					processor(request.urlRequest, failure)
				}
				return failure
			}
			.tryMap { [weak self] response -> (data: Data, response: URLResponse) in
				guard let httpResponse = response.response as? HTTPURLResponse else {
					throw URLError(.badServerResponse)
				}
				// We only want to re auth and other wise just pass the error down
				if let handler = self?.responseHandler, httpResponse.statusCode == 401 {
					try handler(httpResponse)
				}
				return response
			}
			.tryMap { [weak self] result -> Data in
				if self?.configuration.logResponses == true {
					let string = String(data: result.data, encoding: .utf8)
					ALog.info("\(string ?? "")")
				}
				let data = try result.data.ws_validate(result.response).ws_validate()
				return data
			}
			.tryMap { data -> Any in
				try JSONSerialization.jsonObject(with: data, options: .allowFragments)
			}
			.subscribe(on: DispatchQueue.global(qos: .background))
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	func data(request: Request) -> AnyPublisher<Data, Error> {
		session.servicePublisher(for: request)
			.retry(configuration.retryCountForRequest)
			.mapError { [weak self] failure -> Error in
				if let processor = self?.errorProcessor {
					processor(request.urlRequest, failure)
				}
				return failure
			}
			.tryMap { [weak self] response -> (data: Data, response: URLResponse) in
				guard let httpResponse = response.response as? HTTPURLResponse else {
					throw URLError(.badServerResponse)
				}

				// We only want to re auth and other wise just pass the error down
				if let handler = self?.responseHandler, httpResponse.statusCode == 401 {
					try handler(httpResponse)
				}
				return response
			}
			.tryMap { result -> Data in
				try result.data.ws_validate(result.response)
			}
			.subscribe(on: DispatchQueue.global(qos: .background))
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	func simple(request: Request) -> AnyPublisher<Bool, Error> {
		session.servicePublisher(for: request)
			.retry(configuration.retryCountForRequest)
			.mapError { [weak self] failure -> Error in
				if let processor = self?.errorProcessor {
					processor(request.urlRequest, failure)
				}
				return failure
			}
			.tryMap { [weak self] response -> (data: Data, response: URLResponse) in
				guard let httpResponse = response.response as? HTTPURLResponse else {
					throw URLError(.badServerResponse)
				}

				// We only want to re auth and other wise just pass the error down
				if let handler = self?.responseHandler, httpResponse.statusCode == 401 {
					try handler(httpResponse)
				}
				return response
			}
			.tryMap { result -> Bool in
				let data = try? result.data.ws_validate(result.response)
				return data != nil
			}
			.subscribe(on: DispatchQueue.global(qos: .background))
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
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
