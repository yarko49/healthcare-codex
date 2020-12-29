//
//  UnknownModel.swift
//  Alfred
//

import Foundation

protocol UnknownCaseRepresentable: RawRepresentable, CaseIterable where RawValue: Equatable {
	static var unknownCase: Self { get }
}

extension UnknownCaseRepresentable {
	init(rawValue: RawValue) {
		let value = Self.allCases.first(where: { $0.rawValue == rawValue })
		self = value ?? Self.unknownCase
	}
}
