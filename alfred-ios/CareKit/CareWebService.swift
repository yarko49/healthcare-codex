//
//  CareWebService.swift
//  alfred-ios
//
//  Created by Waqar Malik on 11/23/20.
//

import Combine
import Foundation

public final class CareWebService {
	public typealias DecodableCompletion<T: Decodable> = (Result<T, Error>) -> Void
	public typealias DataCompletion<T> = (Result<T, Error>) -> Void

	private let session: URLSession
	private var cancellables: Set<AnyCancellable> = []

	public init(session: URLSession) {
		self.session = session
	}

	public func cancelAll() {
		cancellables.forEach { cancellable in
			cancellable.cancel()
		}
	}

	public func getCarePlan(completion: @escaping CareWebService.DataCompletion<[String: Any]>) {
		request(route: .getCarePlan, completion: completion)
	}

	@discardableResult
	func request<T: Decodable>(route: APIRouter, decoder: JSONDecoder = JSONDecoder(), completion: @escaping CareWebService.DecodableCompletion<T>) -> URLSession.DataTaskPublisher? {
		guard let request = route.urlRequest else {
			completion(.failure(URLError(.badURL)))
			return nil
		}

		let publisher = session.dataTaskPublisher(for: request)
		publisher.tryMap { element -> Data in
			try element.data.cws_validate(element.response).cws_validate()
		}
		.decode(type: T.self, decoder: decoder)
		.receive(on: DispatchQueue.main)
		.sink(receiveCompletion: { receiveCompletion in
			switch receiveCompletion {
			case .failure(let error):
				completion(.failure(error))
			case .finished:
				break
			}
		}, receiveValue: { value in
			completion(.success(value))
		}).store(in: &cancellables)

		return publisher
	}

	@discardableResult
	func request(route: APIRouter, completion: @escaping CareWebService.DataCompletion<[String: Any]>) -> URLSession.DataTaskPublisher? {
		guard let request = route.urlRequest else {
			completion(.failure(URLError(.badURL)))
			return nil
		}

		let publisher = session.dataTaskPublisher(for: request)
		publisher.tryMap { element -> Data in
			try element.data.cws_validate(element.response).cws_validate()
		}
		.tryMap { (data) -> [String: Any] in
			try data.write(to: URL(fileURLWithPath: "/tmp/carePlan.json"))
			guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
				throw URLError(.cannotDecodeContentData)
			}
			return jsonObject
		}
		.receive(on: DispatchQueue.main)
		.sink(receiveCompletion: { receiveCompletion in
			switch receiveCompletion {
			case .failure(let error):
				completion(.failure(error))
			case .finished:
				break
			}
		}, receiveValue: { value in
			completion(.success(value))
		}).store(in: &cancellables)

		return publisher
	}
}
