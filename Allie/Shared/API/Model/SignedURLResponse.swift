//
//  SignedURLResponse.swift
//  Allie
//
//  Created by Waqar Malik on 5/27/21.
//

import Foundation

struct SignedURLResponse: Codable {
	var MD5Hash: String?
	var method: String
	var signedURL: URL

	private enum CodingKeys: String, CodingKey {
		case MD5Hash = "md5Hash"
		case method
		case signedURL = "signedUrl"
	}
}
