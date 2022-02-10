//
//  WebService+Codex.swift
//  Allie
//
//  Created by Waqar Malik on 7/22/21.
//

import CodexFoundation
import Combine
import Foundation
import WebService

extension WebService {
	func decodable<T: Decodable>(route: APIRouter, decoder: JSONDecoder = CHFJSONDecoder()) async throws -> T {
		let request = try route.request()
		return try await decodable(request: request, decoder: decoder)
	}

	func decodable<T: Decodable>(route: APIRouter, decoder: JSONDecoder = CHFJSONDecoder()) -> AnyPublisher<T, Error> {
		do {
			let request = try route.request()
			return decodable(request: request, decoder: decoder)
				.subscribe(on: DispatchQueue.global(qos: .background))
				.receive(on: DispatchQueue.main)
				.eraseToAnyPublisher()
		} catch {
			return Fail(error: error).eraseToAnyPublisher()
		}
	}

	func serializable(route: APIRouter, options: JSONSerialization.ReadingOptions = .allowFragments) async throws -> Any {
		let request = try route.request()
		return try await serializable(request: request, options: options)
	}

	func serializable(route: APIRouter, options: JSONSerialization.ReadingOptions = .allowFragments) -> AnyPublisher<Any, Error> {
		do {
			let request = try route.request()
			return serializable(request: request, options: options)
				.subscribe(on: DispatchQueue.global(qos: .background))
				.receive(on: DispatchQueue.main)
				.eraseToAnyPublisher()
		} catch {
			return Fail(error: error)
				.eraseToAnyPublisher()
		}
	}

	func simple(route: APIRouter) async throws -> Bool {
		let request = try route.request()
		return try await simple(request: request)
	}

	func simple(request: Request) async throws -> Bool {
		let urlRequest = try request.urlRequest()
		let (data, response) = try await session.data(for: urlRequest)
		let validated = try? data.ws_validate(response)
		return validated != nil
	}

	func simple(route: APIRouter) -> AnyPublisher<Bool, Error> {
		do {
			let request = try route.request()
			return simple(request: request)
		} catch {
			return Fail<Bool, Error>(error: error)
				.eraseToAnyPublisher()
		}
	}

	func simple(request: Request) -> AnyPublisher<Bool, Error> {
		session.servicePublisher(for: request)
			.tryMap { result -> Bool in
				let data = try? result.data.ws_validate(result.response)
				return data != nil
			}
			.subscribe(on: DispatchQueue.global(qos: .background))
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}
}
