//
//  URL+RedirectURI.swift
//  Allie
//
//  Created by Waqar Malik on 11/8/21.
//

import Foundation

extension URL {
	var extractRedirectURI: String? {
		let authURLComponents = URLComponents(string: absoluteString)
		let authQueryItems = authURLComponents?.queryItems
		let redirectURI = authQueryItems?.first(where: { item in
			item.name == "redirect_uri"
		})?.value
		return redirectURI
	}
}
