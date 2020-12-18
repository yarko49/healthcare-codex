//
//  QuestionnaireModel.swift
//  alfred-ios
//

import Foundation

// MARK: - QuestionnaireResponse

struct Questionnaire: Codable {
	let resourceType: String?
	let identifier: [QuestionnaireIdentifier]?
	let version, name, title, status: String?
	let date: String?
	var item: [Item]?
}

// MARK: - QuestionnaireIdentifier

struct QuestionnaireIdentifier: Codable {
	let assigner: Assigner?
	let system: String?
	let type: IdentifierID?
	let use, value: String?
}

// MARK: - IdentifierID

struct IdentifierID: Codable {
	let text, value: String?
	let coding: [Coding]?
}

// MARK: - Item

struct Item: Codable {
	let linkID: String
	let code: [CodeElement]?
	let itemPrefix, definition, text: String?
	let type: TypeEnum?
	var selectedAnswerId: String?
	let itemRequired: Bool?
	let answerOption: [AnswerOption]?
	let answer: [Answer]?
	var item: [Item]?

	enum CodingKeys: String, CodingKey {
		case linkID = "linkId"
		case definition, code
		case itemPrefix = "prefix"
		case text, type
		case itemRequired = "required"
		case answerOption, item, selectedAnswerId, answer
	}
}

// MARK: - Answer

struct Answer: Codable {
	let valueBoolean: Bool?
	let valueDecimal, valueInteger: Int?
	let valueDate, valueDateTime, valueTime, valueString: String?
	let valueURI: String?
	let valueQuantity: ValueQuantity?

	enum CodingKeys: String, CodingKey {
		case valueBoolean, valueDecimal, valueInteger, valueDate, valueDateTime, valueTime, valueString
		case valueURI = "valueUri"
		case valueQuantity
	}
}

// MARK: - AnswerOption

struct AnswerOption: Codable {
	let valueString: String?
	let answerOptionExtension: [Extension]?

	enum CodingKeys: String, CodingKey {
		case valueString
		case answerOptionExtension = "extension"
	}
}

// MARK: - Extension

struct Extension: Codable {
	let url: String?
	let valueString: ValueString?
}

enum ValueString: String, Codable {
	case a99D99 = "#A99D99"
	case ae0E04 = "#AE0E04"
	case f13F33 = "#F13F33"
	case fdcf13 = "#FDCF13"
	case ff7A00 = "#FF7A00"
	case the33Db12 = "#33DB12"
}

// MARK: - CodeElement

struct CodeElement: Codable {
	let system: String?
	let code: CodeEnum?
	let display: Display?
}

enum CodeEnum: String, Codable {
	case radioButton = "radio-button"
}

enum Display: String, Codable {
	case radioButton = "Radio Button"
}

enum TypeEnum: String, Codable {
	case choice
	case group
}

func == (lhs: AnswerOption, rhs: AnswerOption) -> Bool {
	var returnValue = false
	if lhs.valueString == rhs.valueString {
		returnValue = true
	}
	return returnValue
}

func != (lhs: AnswerOption, rhs: AnswerOption) -> Bool {
	var returnValue = true
	if lhs.valueString == rhs.valueString {
		returnValue = false
	}
	return returnValue
}
