//
//  QuestionnaireResponseModel.swift
//  alfred-ios
//

import Foundation

// MARK: - QuestionnaireResponse

struct QuestionnaireResponse: Codable {
	let resourceType: String?
	let identifier: QuestionnaireIdentifier?
	let questionnaire, status, authored: String?
	let author: Assigner?
	let source: Subject?
	let item: [Item]?
}

// MARK: - SubmittedQuestionnaire

struct SubmittedQuestionnaire: Codable {
	let author: Subject?
	let authored, id: String?
	let identifier: QuestionnaireIdentifier?
	let item: [Item]?
	let meta: Meta?
	let questionnaire, resourceType: String?
	let source: Subject?
	let status: String?
}
