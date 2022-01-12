//
//  LoggingFile.swift
//  Allie
//
//  Created by Waqar Malik on 1/16/21.
//

import Foundation
import Logging

// Adapted from https://nshipster.com/textoutputstream/
struct FileHandlerOutputStream: TextOutputStream {
	enum FileHandlerOutputStream: Error {
		case couldNotCreateFile
	}

	private let fileHandle: FileHandle
	let encoding: String.Encoding

	init(localFile url: URL, encoding: String.Encoding = .utf8) throws {
		if !FileManager.default.fileExists(atPath: url.path) {
			guard FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil) else {
				throw FileHandlerOutputStream.couldNotCreateFile
			}
		}

		let fileHandle = try FileHandle(forWritingTo: url)
		fileHandle.seekToEndOfFile()
		self.fileHandle = fileHandle
		self.encoding = encoding
	}

	mutating func write(_ string: String) {
		if let data = string.data(using: encoding) {
			fileHandle.write(data)
		}
	}
}

public struct LoggingFile {
	let stream: TextOutputStream
	private var localFile: URL
	static var isEnabled: Bool = false

	public init(to localFile: URL) throws {
		self.stream = try FileHandlerOutputStream(localFile: localFile)
		self.localFile = localFile
	}

	public func handler(label: String) -> FileLogHandler {
		FileLogHandler(label: label, fileLogger: self)
	}

	public static func logger(label: String, localFile url: URL) throws -> Logger {
		let logging = try LoggingFile(to: url)
		return Logger(label: label, factory: logging.handler)
	}
}

// Adapted from https://github.com/apple/swift-log.git

/// `FileLogHandler` is a simple implementation of `LogHandler` for directing
/// `Logger` output to a local file. Appends log output to this file, even across constructor calls.
public struct FileLogHandler: LogHandler {
	private let stream: TextOutputStream
	private var label: String

	public var logLevel: Logger.Level = .info

	private var prettyMetadata: String?
	public var metadata = Logger.Metadata() {
		didSet {
			prettyMetadata = prettify(metadata)
		}
	}

	public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
		get {
			metadata[metadataKey]
		}
		set {
			metadata[metadataKey] = newValue
		}
	}

	public init(label: String, fileLogger: LoggingFile) {
		self.label = label
		self.stream = fileLogger.stream
	}

	public init(label: String, localFile url: URL) throws {
		self.label = label
		self.stream = try FileHandlerOutputStream(localFile: url)
	}

	// swiftlint:disable:next function_parameter_count
	public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
		guard LoggingFile.isEnabled else {
			return
		}
		let prettyMetadata = metadata?.isEmpty ?? true
			? self.prettyMetadata
			: prettify(self.metadata.merging(metadata!, uniquingKeysWith: { _, new in new }))

		var stream = self.stream
		stream.write("\(timestamp()) \(level) \(label) :\(prettyMetadata.map { " \($0)" } ?? "") \(message)\n")
	}

	private func prettify(_ metadata: Logger.Metadata) -> String? {
		!metadata.isEmpty ? metadata.map { "\($0)=\($1)" }.joined(separator: " ") : nil
	}

	private func timestamp() -> String {
		var buffer = [Int8](repeating: 0, count: 255)
		var timestamp = time(nil)
		let localTime = localtime(&timestamp)
		strftime(&buffer, buffer.count, "%Y-%m-%dT%H:%M:%S%z", localTime)
		return buffer.withUnsafeBufferPointer {
			$0.withMemoryRebound(to: CChar.self) {
				String(cString: $0.baseAddress!)
			}
		}
	}
}
