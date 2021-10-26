//
//  CHLink.swift
//  Allie
//
//  Created by Waqar Malik on 8/4/21.
//

import CareKitStore
import CareKitUI
import CoreLocation
import Foundation

enum CHLinkType: String, Codable {
	case appStore
	case call
	case email
	case location
	case message
	case url
	case website
}

struct CHLink: Codable {
	let type: CHLinkType
	let title: String
	let appStore: String?
	let call: String?
	let email: String?
	let latitude: String?
	let longitude: String?
	let message: String?
	let url: URL?
	let website: String?
	let symbol: String?

	var location: CLLocationCoordinate2D? {
		guard let lat = CLLocationDegrees(latitude ?? ""), let long = CLLocationDegrees(longitude ?? "") else {
			return nil
		}
		return CLLocationCoordinate2D(latitude: lat, longitude: long)
	}

	private enum CodingKeys: String, CodingKey {
		case type
		case title
		case appStore
		case call
		case email
		case latitude
		case longitude
		case message
		case url
		case website
		case symbol
	}
}

extension CHLink {
	var linkItem: LinkItem? {
		switch type {
		case .appStore:
			guard let value = appStore else {
				return nil
			}
			return LinkItem.appStore(id: value, title: title)
		case .call:
			guard let value = call else {
				return nil
			}
			return LinkItem.call(phoneNumber: value, title: title)
		case .email:
			guard let value = email else {
				return nil
			}
			return LinkItem.email(recipient: value, title: title)
		case .location:
			guard let lat = latitude, let long = longitude else {
				return nil
			}
			return LinkItem.location(lat, long, title: title)
		case .message:
			guard let value = message else {
				return nil
			}
			return LinkItem.message(phoneNumber: value, title: title)
		case .url:
			guard let value = url else {
				return nil
			}
			return LinkItem.url(value, title: title, symbol: symbol ?? "safari.fill")
		case .website:
			guard let value = website else {
				return nil
			}
			return LinkItem.website(value, title: title)
		}
	}
}
