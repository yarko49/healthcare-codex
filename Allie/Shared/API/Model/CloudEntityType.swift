//
//  CloudEntityType.swift
//  Allie
//
//  Created by Waqar Malik on 11/4/21.
//

import Foundation

protocol CloudEntityType {
	var id: String { get }
	var name: String { get }
	var imageURL: URL? { get }
	var authURL: URL? { get }
	var info: String? { get }
	var authorizationToken: String? { get }
	var state: String? { get }
}

extension CHOrganization: CloudEntityType {}
extension CHCloudDevice: CloudEntityType {}
