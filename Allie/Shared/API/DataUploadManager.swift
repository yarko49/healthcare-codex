//
//  DataUploadManager.swift
//  Allie
//
//  Created by Waqar Malik on 5/2/21.
//

import Foundation

class DataUploadManager<DownloadType: Decodable>: NSObject, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {
	private var downloadedData: Data?
	private(set) lazy var session: URLSession = {
		URLSession(configuration: DataUploadManager.backgroundSessionConfiguration, delegate: self, delegateQueue: nil)
	}()

	static var sessionIdentifier: String {
		let bundleIdentifier = Bundle.main.bundleIdentifier!
		return bundleIdentifier + ".networking"
	}

	static var backgroundSessionConfiguration: URLSessionConfiguration {
		let config = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
		config.sessionSendsLaunchEvents = true
		config.httpMaximumConnectionsPerHost = 1
		return config
	}

	private var route: APIRouter
	private var completionHandler: ((Result<DownloadType, Error>) -> Void)?

	required init(route: APIRouter, completionHandler: ((Result<DownloadType, Error>) -> Void)?) {
		self.route = route
		self.completionHandler = completionHandler
		super.init()
	}

	private var task: URLSessionUploadTask?
	func start() throws {
		guard var urlRequest = route.urlRequest, let data = urlRequest.httpBody else {
			throw URLError(.badURL)
		}

		let tempDir = FileManager.default.temporaryDirectory
		let localURL = tempDir.appendingPathComponent("uploaddata").appendingPathExtension("bin")
		try data.write(to: localURL)
		urlRequest.httpBody = nil
		task = session.uploadTask(with: urlRequest, fromFile: localURL)
		task?.resume()
	}

	func cancel() {
		task?.cancel()
	}

	func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
		ALog.info("urlSessionDidFinishEventsForBackgroundURLSession")
	}

	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		ALog.info("urlSession:dataTask:didReceiveData:")
		if downloadedData == nil {
			downloadedData = Data()
		}
		downloadedData?.append(data)
	}

	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		ALog.info("urlSession:task:didReceive:didCompleteWithError:")
		defer {
			self.completionHandler = nil
		}

		guard error == nil else {
			ALog.error("Upload outcomes error \(String(describing: error?.localizedDescription))")
			completionHandler?(.failure(error ?? URLError(.badServerResponse)))
			return
		}

		guard let httpURLResponse = task.response as? HTTPURLResponse else {
			ALog.error("Invalid server response")
			completionHandler?(.failure(URLError(.cannotParseResponse)))
			return
		}

		ALog.info("httpResponse status code \(httpURLResponse.statusCode)")
		let validResponses = 200 ..< 300
		guard validResponses.contains(httpURLResponse.statusCode) else {
			let error = URLError(.init(rawValue: httpURLResponse.statusCode))
			ALog.error("Invalid server response \(error.localizedDescription)")
			completionHandler?(.failure(error))
			return
		}

		guard let data = downloadedData, !data.isEmpty else {
			ALog.error("Missing data")
			completionHandler?(.failure(URLError(.cannotDecodeRawData)))
			return
		}

		let decoder = CHJSONDecoder()
		do {
			let decoded = try decoder.decode(DownloadType.self, from: data)
			completionHandler?(.success(decoded))
		} catch {
			ALog.error("Unable to decode response")
			completionHandler?(.failure(error))
		}
	}
}
