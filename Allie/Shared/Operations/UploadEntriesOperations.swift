//
//  UploadEntriesOperations.swift
//  Allie
//
//  Created by Waqar Malik on 3/13/21.
//

import Foundation
import ModelsR4

protocol EntriesResultProvider {
	var entries: [ModelsR4.BundleEntry]? { get }
}

class EntriesUploadOperation: AsynchronousOperation, EntriesResultProvider {
	var entries: [ModelsR4.BundleEntry]?
	var error: Error?
	var completionHandler: ((Result<[ModelsR4.BundleEntry], Error>) -> Void)?
	var uploadEntries: [ModelsR4.BundleEntry]
	var chunkSize: Int
	init(entries: [ModelsR4.BundleEntry], chunkSize: Int, callbackQueue: DispatchQueue = .main, completion: ((Result<[ModelsR4.BundleEntry], Error>) -> Void)? = nil) {
		self.uploadEntries = entries
		self.completionHandler = completion
		self.chunkSize = chunkSize
		super.init()
		self.callbackQueue = callbackQueue
	}

	override func main() {
		let chunkedEntries = uploadEntries.chunked(into: chunkSize)
		var previousOperation: BundleUploadOperation?
		for chunk in chunkedEntries {
			let bundle = ModelsR4.Bundle(entry: chunk, type: FHIRPrimitive<BundleType>(.transaction))
			let operation = BundleUploadOperation(bundle: bundle) { [weak self] result in
				switch result {
				case .failure(let error):
					self?.error = error
				case .success(let bundle):
					if let entries = bundle.entry {
						self?.entries?.append(contentsOf: entries)
					}
				}
			}
			if let previousOperation = previousOperation {
				operation.addDependency(previousOperation)
			}
			operationQueue.addOperation(operation)
			previousOperation = operation
		}
	}

	private func complete() {
		guard let handler = completionHandler else {
			finish()
			return
		}
		callbackQueue.async { [weak self] in
			if let results = self?.entries, self?.error == nil {
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
