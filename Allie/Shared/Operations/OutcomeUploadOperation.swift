//
//  OutcomeUploadOperation.swift
//  Allie
//
//  Created by Waqar Malik on 11/29/21.
//

import Foundation

protocol OutcomesResultProvider {
	var outcomes: [CHOutcome]? { get }
}

enum OutcomeUploadError: Error {
	case missing(String)
	case query(String)
}

class OutcomesUploadOperation: AsynchronousOperation, OutcomesResultProvider {
	var outcomes: [CHOutcome]?
	var error: Error?
	var completionHandler: ((Result<[CHOutcome], Error>) -> Void)?
	var chunkSize: Int
	@Injected(\.networkAPI) var networkAPI: AllieAPI
	@Injected(\.careManager) var careManager: CareManager

	init(chunkSize: Int, callbackQueue: DispatchQueue, completion: ((Result<[CHOutcome], Error>) -> Void)? = nil) {
		self.chunkSize = chunkSize
		super.init()
		self.callbackQueue = callbackQueue
		self.completionHandler = completion
	}

	func upload(outcomes: [CHOutcome], completion: @escaping AllieResultCompletion<[CHOutcome]>) {
		guard !outcomes.isEmpty else {
			completion(.success([]))
			return
		}
		let chunkedOutcomes = outcomes.chunked(into: chunkSize)
		let group = DispatchGroup()
		var errors: [Error] = []
		var uploaded: [CHOutcome] = []
		for chunkOutcome in chunkedOutcomes {
			group.enter()
			networkAPI.post(outcomes: chunkOutcome)
				.sink { completionResult in
					switch completionResult {
					case .failure(let error):
						errors.append(error)
						group.leave()
					case .finished:
						break
					}
				} receiveValue: { carePlanResponse in
					uploaded.append(contentsOf: carePlanResponse.outcomes)
					group.leave()
				}.store(in: &cancellables)
		}

		group.notify(queue: callbackQueue) {
			if !uploaded.isEmpty, errors.isEmpty {
				completion(.success(uploaded))
			} else {
				completion(.failure(AllieError.compound(errors)))
			}
		}
	}

	func complete() {
		guard let handler = completionHandler else {
			finish()
			return
		}
		callbackQueue.async { [weak self] in
			if let results = self?.outcomes, self?.error == nil {
				handler(.success(results))
			} else if let error = self?.error {
				handler(.failure(error))
			} else {
				handler(.failure(URLError(.badServerResponse)))
			}
		}
		finish()
	}
}
