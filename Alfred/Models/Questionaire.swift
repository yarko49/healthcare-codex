//
//  Questionaire.swift
//  alfred-ios
//

import Foundation

// TODO: This model is a fake for testing purpose. Don't forget to replace it with the proper one when time comes.

struct Questionaire: Codable {
	let data: [Question]
}

struct Question: Codable {
	let id: String
	let desc: String
	let questionParts: [QuestionPart]

	enum CodingKeys: String, CodingKey {
		case id
		case desc = "description"
		case questionParts
	}
}

struct QuestionPart: Codable {
	let id: String
	let title: String
	let answers: [Answer]

	enum CodingKeys: String, CodingKey {
		case id
		case title
		case answers
	}
}

struct Answer: Codable {
	let id: String
	let text: String
	let type: String
	let isSelected: Bool

	enum CodingKeys: String, CodingKey {
		case id, text, type, isSelected
	}
}

func == (lhs: Answer, rhs: Answer) -> Bool {
	var returnValue = false
	if lhs.id == rhs.id {
		returnValue = true
	}
	return returnValue
}

func != (lhs: Answer, rhs: Answer) -> Bool {
	var returnValue = true
	if lhs.id == rhs.id {
		returnValue = false
	}
	return returnValue
}
