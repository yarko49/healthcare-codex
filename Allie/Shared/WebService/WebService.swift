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
	var subscriptions: Set<AnyCancellable> = []
	public var configuration: WebService.Configuarion = Configuarion()
	public var errorProcessor: ((URLRequest?, Error) -> Void)?
	public var responseHandler: ((HTTPURLResponse) throws -> Void)?

	public init(session: URLSession = .shared) {
		self.session = session
	}

	public func cancelAll() {
		subscriptions.forEach { cancellable in
			cancellable.cancel()
		}
	}

	func request<T: Decodable>(route: APIRouter, decoder: JSONDecoder = CHJSONDecoder(), completion: @escaping WebService.DecodableCompletion<T>) -> URLSession.ServicePublisher? {
		guard let request = route.request else {
			completion(.failure(URLError(.badURL)))
			return nil
		}
		return self.request(request: request, decoder: decoder, completion: completion)
	}

	func requestSerializable(route: APIRouter, completion: @escaping WebService.RequestCompletion<[String: Any]>) -> URLSession.ServicePublisher? {
		guard let request = route.request else {
			completion(.failure(URLError(.badURL)))
			return nil
		}
		return requestSerializable(request: request, completion: completion)
	}

	func requestSimple(route: APIRouter, completion: @escaping WebService.RequestCompletion<Bool>) -> URLSession.ServicePublisher? {
		guard let request = route.request else {
			completion(.failure(URLError(.badURL)))
			return nil
		}
		return requestSimple(request: request, completion: completion)
	}

	func requestData(url: URL) -> Future<Data, Error> {
		Future { promise in
			self.session.dataTaskPublisher(for: url)
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
				.sink { completion in
					switch completion {
					case .failure(let error):
						promise(.failure(error))
					case .finished:
						break
					}
				} receiveValue: { value in
					promise(.success(value))
				}.store(in: &self.subscriptions)
		}
	}

	func request<T: Decodable>(request: Request, decoder: JSONDecoder = CHJSONDecoder(), completion: @escaping WebService.DecodableCompletion<T>) -> URLSession.ServicePublisher? {
		let publisher = session.servicePublisher(for: request)
		publisher.retry(configuration.retryCountForRequest)
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
			.sink(receiveCompletion: { receiveCompletion in
				switch receiveCompletion {
				case .failure(let error):
					ALog.error(error: error)
					completion(.failure(error))
				case .finished:
					ALog.info("Finished Dowloading")
				}
			}, receiveValue: { value in
				completion(.success(value))
			}).store(in: &subscriptions)
		return publisher
	}

	func requestSerializable(request: Request, completion: @escaping WebService.RequestCompletion<[String: Any]>) -> URLSession.ServicePublisher? {
		let publisher = session.servicePublisher(for: request)
		publisher.retry(configuration.retryCountForRequest)
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
			.tryMap { data -> [String: Any] in
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
					ALog.error(error: error)
					completion(.failure(error))
				case .finished:
					ALog.info("Finished Dowloading")
				}
			}, receiveValue: { value in
				completion(.success(value))
			}).store(in: &subscriptions)
		return publisher
	}

	func requestSimple(request: Request, completion: @escaping WebService.RequestCompletion<Bool>) -> URLSession.ServicePublisher? {
		let publisher = session.servicePublisher(for: request)
		publisher.retry(configuration.retryCountForRequest)
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
				let data = try result.data.ws_validate(result.response)
				return data
			}
			.subscribe(on: DispatchQueue.global(qos: .background))
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { receiveCompletion in
				switch receiveCompletion {
				case .failure(let error):
					ALog.error(error: error)
					completion(.failure(error))
				case .finished:
					ALog.info("Finished Dowloading")
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
