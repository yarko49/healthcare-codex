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

public enum CHLinkType: String, Codable {
	case appStore
	case call
	case email
	case location
	case message
	case url
	case website
}

public struct CHLink: Codable, Equatable {
	public let type: CHLinkType
	public let title: String
	public let appStore: String?
	public let call: String?
	public let email: String?
	public let latitude: String?
	public let longitude: String?
	public let message: String?
	public let url: URL?
	public let website: String?
	public let symbol: String?

	public var location: CLLocationCoordinate2D? {
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
