//
//  BundleUploadOperation.swift
//  Allie
//
//  Created by Waqar Malik on 3/13/21.
//

import Foundation
import ModelsR4

protocol BundleResultProvider {
	var bundle: ModelsR4.Bundle? { get }
}

class BundleUploadOperation: AsynchronousOperation, BundleResultProvider {
	var bundle: ModelsR4.Bundle?
	var error: Error?
	var completionHandler: ((Result<ModelsR4.Bundle, Error>) -> Void)?
	var uploadBundle: ModelsR4.Bundle
	init(bundle: ModelsR4.Bundle, callbackQueue: DispatchQueue = .main, completion: ((Result<ModelsR4.Bundle, Error>) -> Void)? = nil) {
		self.uploadBundle = bundle
		self.completionHandler = completion
		super.init()
		self.callbackQueue = callbackQueue
	}

	override func main() {
		APIClient.client.postBundle(bundle: uploadBundle) { [weak self] result in
			defer {
				self?.complete()
			}
			switch result {
			case .failure(let error):
				self?.error = error
			case .success(let bundle):
				self?.bundle = bundle
			}
		}
	}

	private func complete() {
		guard let handler = completionHandler else {
			finish()
			return
		}
		callbackQueue.async { [weak self] in
			if let results = self?.bundle, self?.error == nil {
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
