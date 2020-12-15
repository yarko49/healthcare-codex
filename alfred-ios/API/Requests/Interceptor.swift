//
//  Interceptor.swift
//  alfred-ios
//

import Alamofire
import AlfredCore
import FirebaseAuth
import Foundation
import os.log

extension OSLog {
	static let interceptor = OSLog(subsystem: subsystem, category: "Interceptor")
}

typealias RequestRetryCompletion = (RetryResult) -> Void

class Interceptor: RequestInterceptor {
	private let lock = NSLock()

	var authToken: String? {
		DataContext.shared.authToken
	}

	var isRefreshing = false
	private var requestsToRetry: [RequestRetryCompletion] = []

	// MARK: - RequestRetrier

	func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
		lock.lock(); defer { lock.unlock() }

		os_log(.error, log: .interceptor, "retry session dueTo error %@", error.localizedDescription)
		if let httpResponse = request.task?.response as? HTTPURLResponse, [401, 403].contains(httpResponse.statusCode) {
			requestsToRetry.append(completion)

			if !isRefreshing {
				initiateRefresh(with: httpResponse.statusCode)
			}
		} else {
			completion(.doNotRetry)
		}
	}

	private func initiateRefresh(with statusCode: Int) {
		let completion: RequestRetryCompletion = { [weak self] result in
			self?.lock.lock(); defer { self?.lock.unlock() }
			self?.requestsToRetry.forEach {
				$0(result)
			}
			self?.requestsToRetry.removeAll()
		}
		refreshTokens(completion: completion)
	}

	func refreshTokens(completion: @escaping RequestRetryCompletion) {
		guard !isRefreshing else { return }

		isRefreshing = true
		Auth.auth().currentUser?.getIDToken(completion: { [weak self] firebaseToken, error in
			self?.isRefreshing = false
			if error != nil {
				completion(.retry)
			} else if let firebaseToken = firebaseToken {
				DataContext.shared.authToken = firebaseToken
				completion(.doNotRetry)
			}
		})
	}

	// MARK: - RequestAdapter

	func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
		var urlRequestToSend = urlRequest
		if let token = authToken {
			urlRequestToSend.setValue("Bearer \(token)", forHTTPHeaderField: WebService.Header.userAuthorization)
		}
		completion(.success(urlRequestToSend))
	}
}
