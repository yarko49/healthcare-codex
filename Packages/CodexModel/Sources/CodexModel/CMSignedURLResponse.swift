//
//  CMSignedURLResponse.swift
//  Allie
//
//  Created by Waqar Malik on 5/27/21.
//

import Foundation

public struct CMSignedURLResponse: Codable {
	public var MD5Hash: String?
	public var method: String
	public var signedURL: URL

	private enum CodingKeys: String, CodingKey {
		case MD5Hash = "md5Hash"
		case method
		case signedURL = "signedUrl"
	}
}

extension CMSignedURLResponse: CustomStringConvertible {
	public var description: String {
		"{\nMD5hash = \(MD5Hash ?? "")\nmethod = \(method)\nsignedURL = \(signedURL)\n}"
	}
}
