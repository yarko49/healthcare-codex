//
//  APIClient+Injectable.swift
//  Allie
//
//  Created by Waqar Malik on 8/15/21.
//

import Foundation

private struct APIClientKey: InjectionKey {
	static var currentValue: AllieAPI = APIClient()
}

extension InjectedValues {
	var networkAPI: AllieAPI {
		get { Self[APIClientKey.self] }
		set { Self[APIClientKey.self] = newValue }
	}
}
