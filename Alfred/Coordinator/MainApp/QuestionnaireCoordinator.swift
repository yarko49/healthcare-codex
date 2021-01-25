//
//  QuestionnaireCoordinator.swift
//  Alfred
//

import Foundation
import UIKit

class QuestionnaireCoordinator: NSObject, Coordinator {
	internal var navigationController: UINavigationController? = {
		let navigationController = UINavigationController()
		let navBar = navigationController.navigationBar
		navBar.barTintColor = UIColor.lightBackground
		navBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24.0, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.black]

		return navigationController
	}()

	internal var childCoordinators: [CoordinatorKey: Coordinator]
	internal weak var parentCoordinator: MainAppCoordinator?

	var rootViewController: UIViewController? {
		navigationController
	}

	var questions: [Item] = []
	weak var questionViewController: QuestionViewController?

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
		let questionnaireViewController = QuestionnaireViewController()
		questionnaireViewController.closeAction = { [weak self] in
			self?.stop()
		}
		questionnaireViewController.showQuestionnaireAction = { [weak self] in
			self?.showHUD()
			AlfredClient.client.getQuestionnaire { result in
				self?.hideHUD()
				switch result {
				case .failure(let error):
					ALog.error("Error Fetching Questionnaire", error: error)
				case .success(let questionnaire):
					if let items = questionnaire.item, let question = items.first {
						self?.showQuestion(with: items, currentQuestion: question)
					}
				}
			}
		}
		navigationController?.viewControllers = [questionnaireViewController]
	}

	internal func showQuestion(with questions: [Item], currentQuestion: Item) {
		let questionController = questionViewController ?? QuestionViewController()
		let currentQuestionIndex = self.questions.firstIndex(where: { $0.linkID == currentQuestion.linkID }) ?? 0

		var answeredQuestion = currentQuestion

		questionViewController = questionController
		self.questions = questions
		questionController.question = currentQuestion
		questionController.totalQuestions = questions.count
		questionController.currentQuestionIndex = currentQuestionIndex

		questionController.nextQuestionAction = { [weak self] in
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

		questionController.onQuestionPartAnsweredAction = { selectedAnswerId, questionPartId in
			switch currentQuestion.type {
			case .group:
				if let questionPart = currentQuestion.item, let currenQuestionPartIndex = questionPart.firstIndex(where: { $0.linkID == questionPartId }) {
					answeredQuestion.item?[currenQuestionPartIndex].selectedAnswerId = selectedAnswerId
				}

				if let answeredQuestionPart = answeredQuestion.item {
					if !answeredQuestionPart.contains(where: { $0.selectedAnswerId == nil }) {
						self.questionViewController?.allQuestionPartsAnswered()
					} else if answeredQuestion.item!.last?.linkID != questionPartId, let index = answeredQuestionPart.firstIndex(where: { $0.linkID == questionPartId })?.advanced(by: 1) {
						self.questionViewController?.moveToTheNextQuestionPart(by: index)
					}
				}
			case .choice:
				answeredQuestion.selectedAnswerId = selectedAnswerId
				self.questionViewController?.allQuestionPartsAnswered()
			default:
				break
			}
		}

		if navigationController?.viewControllers.contains(questionController) ?? false {
			questionViewController?.setupQuestion()
		} else {
			navigate(to: questionController, with: .pushFullScreen)
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
				ALog.error("Cannot post questionnaire response", error: error)
			case .success:
				self?.goToQuestionnaireCompletion()
			}
		}
	}

	internal func goToQuestionnaireCompletion() {
		let questionnaireCompletionViewController = QuestionnaireCompletionViewController()
		questionnaireCompletionViewController.closeAction = { [weak self] in
			self?.navigationController?.popViewController(animated: false)
			self?.cancelAction()
		}
		navigate(to: questionnaireCompletionViewController, with: .pushFullScreen)
	}

	internal func stop() {
		rootViewController?.dismiss(animated: true, completion: { [weak self] in
			guard let self = self else { return }
			self.parentCoordinator?.removeChild(.questionnaireCoordinator)
			if let visibleController = self.parentCoordinator?.navigationController?.visibleViewController, let homeViewController = visibleController as? HomeViewController {
				homeViewController.viewWillAppear(true)
			}
		})
	}

	deinit {
		navigationController?.viewControllers = []
		rootViewController?.dismiss(animated: true, completion: nil)
	}

	@objc internal func backAction() {
		guard let question = questionViewController?.question, let currentQuestionIndex = questions.firstIndex(where: { $0.linkID == question.linkID }) else { return }

		let previousQuestionIndex = currentQuestionIndex - 1

		if previousQuestionIndex < 0 {
			questionViewController = nil
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
		ALog.info("dismiss")
		stop()
	}
}
