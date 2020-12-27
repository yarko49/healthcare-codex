//
//  QuestionnaireCoordinator.swift
//  alfred-ios
//

import Foundation
import os.log
import UIKit

extension OSLog {
	static let questionnaireCoordinator = OSLog(subsystem: subsystem, category: "QuestionnaireCoordinator")
}

class QuestionnaireCoordinator: NSObject, Coordinator {
	internal var navigationController: UINavigationController? = {
		QuestionnaireNavigationController()
	}()

	internal var childCoordinators: [CoordinatorKey: Coordinator]
	internal weak var parentCoordinator: MainAppCoordinator?

	var rootViewController: UIViewController? {
		navigationController
	}

	var questions: [Item] = []
	weak var questionVC: QuestionViewController?

	init(with parent: MainAppCoordinator?) {
		self.parentCoordinator = parent
		self.childCoordinators = [:]
		super.init()
		navigationController?.delegate = self
	}

	internal func start() {
		goToQuestionnaire()
		if let nav = rootViewController {
			nav.presentationController?.delegate = self
			parentCoordinator?.navigate(to: nav, with: .present)
		}
	}

	func showHUD(animated: Bool = true) {
		parentCoordinator?.showHUD(animated: animated)
	}

	func hideHUD(animated: Bool = true) {
		parentCoordinator?.hideHUD(animated: animated)
	}

	internal func goToQuestionnaire() {
		let questionnaireVC = QuestionnaireViewController()
		questionnaireVC.closeAction = { [weak self] in
			self?.stop()
		}
		questionnaireVC.showQuestionnaireAction = { [weak self] in
			self?.showHUD()
			AlfredClient.client.getQuestionnaire { result in
				self?.hideHUD()
				switch result {
				case .failure(let error):
					os_log(.error, log: .questionnaireCoordinator, "Error Fetching Questionnaire %@", error.localizedDescription)
				case .success(let questionnaire):
					if let items = questionnaire.item, let question = items.first {
						self?.showQuestion(with: items, currentQuestion: question)
					}
				}
			}
		}
		navigationController?.viewControllers = [questionnaireVC]
	}

	internal func showQuestion(with questions: [Item], currentQuestion: Item) {
		let questionVC = self.questionVC ?? QuestionViewController()
		let currentQuestionIndex = self.questions.firstIndex(where: { $0.linkID == currentQuestion.linkID }) ?? 0

		var answeredQuestion = currentQuestion

		self.questionVC = questionVC
		self.questions = questions
		questionVC.question = currentQuestion
		questionVC.totalQuestions = questions.count
		questionVC.currentQuestionIndex = currentQuestionIndex

		questionVC.nextQuestionAction = { [weak self] in
			let nextQuestionIndex = currentQuestionIndex + 1

			self?.questions[currentQuestionIndex] = answeredQuestion

			if nextQuestionIndex < questions.count {
				if let questions = self?.questions {
					self?.showQuestion(with: questions, currentQuestion: questions[nextQuestionIndex])
				}
			} else {
				if let questionnaireResponse = self?.createQuestionnaireResponse() {
					self?.postRequest(with: questionnaireResponse)
				}
			}
		}

		questionVC.onQuestionPartAnsweredAction = { selectedAnswerId, questionPartId in
			switch currentQuestion.type {
			case .group:
				if let questionPart = currentQuestion.item, let currenQuestionPartIndex = questionPart.firstIndex(where: { $0.linkID == questionPartId }) {
					answeredQuestion.item?[currenQuestionPartIndex].selectedAnswerId = selectedAnswerId
				}

				if let answeredQuestionPart = answeredQuestion.item {
					if !answeredQuestionPart.contains(where: { $0.selectedAnswerId == nil }) {
						self.questionVC?.allQuestionPartsAnswered()
					} else if answeredQuestion.item!.last?.linkID != questionPartId, let index = answeredQuestionPart.firstIndex(where: { $0.linkID == questionPartId })?.advanced(by: 1) {
						self.questionVC?.moveToTheNextQuestionPart(by: index)
					}
				}
			case .choice:
				answeredQuestion.selectedAnswerId = selectedAnswerId
				self.questionVC?.allQuestionPartsAnswered()
			default:
				break
			}
		}

		if navigationController?.viewControllers.contains(questionVC) ?? false {
			self.questionVC?.setupQuestion()
		} else {
			navigate(to: questionVC, with: .pushFullScreen)
		}
	}

	internal func createQuestionnaireResponse() -> QuestionnaireResponse? {
		var items: [Item] = []
		for question in questions {
			var subAnswers: [Answer] = []
			if let questionPart = question.item {
				for part in questionPart {
					let answer = Answer(valueBoolean: nil, valueDecimal: nil, valueInteger: nil, valueDate: nil, valueDateTime: nil, valueTime: nil, valueString: part.selectedAnswerId, valueURI: nil, valueQuantity: nil)
					subAnswers.append(answer)
				}
			} else {
				subAnswers = [Answer(valueBoolean: nil, valueDecimal: nil, valueInteger: nil, valueDate: nil, valueDateTime: nil, valueTime: nil, valueString: question.selectedAnswerId, valueURI: nil, valueQuantity: nil)]
			}
			let item = Item(linkID: question.linkID, code: nil, itemPrefix: nil, definition: nil, text: nil, type: nil, selectedAnswerId: nil, itemRequired: nil, answerOption: nil, answer: subAnswers, item: nil)
			items.append(item)
		}

		let questionnaireResponse = QuestionnaireResponse(resourceType: "QuestionnaireResponse", identifier: QuestionnaireIdentifier(assigner: nil, system: nil, type: IdentifierID(text: "", value: "", coding: DataContext.shared.hrCode.coding), use: nil, value: nil), questionnaire: "string", status: "completed", authored: DateFormatter.wholeDateRequest.string(from: Date()), author: Assigner(reference: DataContext.shared.patientID), source: Subject(reference: DataContext.shared.patientID, type: "Patient", identifier: nil, display: DataContext.shared.displayName), item: items)
		return questionnaireResponse
	}

	internal func postRequest(with questionnaireResponse: QuestionnaireResponse) {
		showHUD()
		AlfredClient.client.postQuestionnaireResponse(questionnaireResponse: questionnaireResponse) { [weak self] result in
			self?.hideHUD()
			switch result {
			case .failure(let error):
				os_log(.error, log: .questionnaireCoordinator, "Cannot post questionnaire response %@", error.localizedDescription)
			case .success:
				self?.goToQuestionnaireCompletion()
			}
		}
	}

	internal func goToQuestionnaireCompletion() {
		let questionnaireCompletionVC = QuestionnaireCompletionViewController()
		questionnaireCompletionVC.closeAction = { [weak self] in
			self?.navigationController?.popViewController(animated: false)
			self?.cancelAction()
		}
		navigate(to: questionnaireCompletionVC, with: .pushFullScreen)
	}

	internal func stop() {
		rootViewController?.dismiss(animated: true, completion: { [weak self] in
			guard let self = self else { return }
			self.parentCoordinator?.removeChild(.questionnaireCoordinator)
			if let visibleController = self.parentCoordinator?.navigationController?.visibleViewController, let homeVC = visibleController as? HomeViewController {
				homeVC.viewWillAppear(true)
			}
		})
	}

	deinit {
		navigationController?.viewControllers = []
		rootViewController?.dismiss(animated: true, completion: nil)
	}

	@objc internal func backAction() {
		guard let question = questionVC?.question, let currentQuestionIndex = questions.firstIndex(where: { $0.linkID == question.linkID }) else { return }

		let previousQuestionIndex = currentQuestionIndex - 1

		if previousQuestionIndex < 0 {
			questionVC = nil
			questions = []
			navigationController?.popViewController(animated: true)
		} else {
			let previousQuestion = questions[previousQuestionIndex]
			showQuestion(with: questions, currentQuestion: previousQuestion)
		}
	}

	@objc internal func cancelAction() {
		navigationController?.popViewController(animated: false)
		stop()
	}
}

extension QuestionnaireCoordinator: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		if viewController is QuestionViewController {
			viewController.navigationItem.hidesBackButton = true

			if viewController.navigationItem.leftBarButtonItem == nil {
				let backBtn = UIButton(type: .system)
				backBtn.setImage(UIImage(named: "back"), for: .normal)
				backBtn.setTitle(Str.previous, for: .normal)
				backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
				backBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
				backBtn.sizeToFit()
				viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
			}

			if viewController.navigationItem.rightBarButtonItem == nil {
				let cancelBtn = UIBarButtonItem(title: Str.cancel, style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelAction))
				viewController.navigationItem.setRightBarButton(cancelBtn, animated: true)
			}
		}
	}
}

extension QuestionnaireCoordinator: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		os_log(.info, log: .questionnaireCoordinator, "dismiss")
		stop()
	}
}
