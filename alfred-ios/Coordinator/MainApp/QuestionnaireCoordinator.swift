//
//  QuestionnaireCoordinator.swift
//  alfred-ios
//

import Foundation
import UIKit

class QuestionnaireCoordinator: NSObject, Coordinator {
    
    
    internal var navigationController: UINavigationController?
    internal var childCoordinators: [CoordinatorKey:Coordinator]
    internal weak var parentCoordinator: MainAppCoordinator?
    
    var rootViewController: UIViewController? {
        return navigationController
    }
    
    var questions: [Item] = []
    weak var questionVC: QuestionVC?
    
    init(with parent: MainAppCoordinator?){
        self.navigationController = QuestionnaireNC()
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
    
    internal func goToQuestionnaire() {
        let questionnaireVC = QuestionnaireVC()
        questionnaireVC.closeAction = { [weak self] in
            self?.stop()
        }
        questionnaireVC.showQuestionnaireAction = { [weak self] in
            AlertHelper.showLoader()
            DataContext.shared.getQuestionnaire { (questions) in
                AlertHelper.hideLoader()
                if let questions = questions, let question = questions.first {
                    self?.showQuestion(with: questions, currentQuestion: question)
                }
            }
            
        }
        self.navigationController?.viewControllers = [questionnaireVC]
    }
    
    internal func showQuestion(with questions: [Item], currentQuestion: Item ) {
        let questionVC = self.questionVC ?? QuestionVC()
        let currentQuestionIndex = self.questions.firstIndex(where: {$0.linkID == currentQuestion.linkID}) ?? 0
        
        var answeredQuestion = currentQuestion
        
        self.questionVC = questionVC
        self.questions = questions
        questionVC.question = currentQuestion
        questionVC.totalQuestions = questions.count
        questionVC.currentQuestionIndex = currentQuestionIndex

        questionVC.nextQuestionAction = {
            let nextQuestionIndex = currentQuestionIndex + 1
            
            self.questions[currentQuestionIndex] = answeredQuestion
            
            if nextQuestionIndex < questions.count {
                self.showQuestion(with: self.questions, currentQuestion: self.questions[nextQuestionIndex])
            } else {
                //TODO: Completion Screen
                print(self.questions)
            }
        }
        
        questionVC.onQuestionPartAnsweredAction = { selectedAnswerId, questionPartId in
            switch currentQuestion.type {
            case .group:
                if let questionPart = currentQuestion.item, let currenQuestionPartIndex = questionPart.firstIndex(where: {$0.linkID == questionPartId}) {
                    answeredQuestion.item?[currenQuestionPartIndex].selectedAnswerId = selectedAnswerId
                }
                
                if let answeredQuestionPart = answeredQuestion.item {
                    if  !answeredQuestionPart.contains(where: {$0.selectedAnswerId == nil}) {
                        self.questionVC?.allQuestionPartsAnswered()
                    } else if answeredQuestion.item!.last?.linkID != questionPartId, let index = answeredQuestionPart.firstIndex(where: {$0.linkID == questionPartId})?.advanced(by: 1) {
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
            self.navigate(to: questionVC, with: .pushFullScreen)
        }
    }
    
    
    internal func stop() {
        rootViewController?.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            self.parentCoordinator?.removeChild(.questionnaireCoordinator)
        })
    }
 
    deinit {
        navigationController?.viewControllers = []
        rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc internal func backAction(){
        guard let question = questionVC?.question, let currentQuestionIndex = self.questions.firstIndex(where: {$0.linkID == question.linkID}) else { return }
        
        let previousQuestionIndex = currentQuestionIndex - 1
        
        if previousQuestionIndex < 0  {
            self.questionVC = nil
            questions = []
            self.navigationController?.popViewController(animated: true)
        } else {
            let previousQuestion = self.questions[previousQuestionIndex]
            showQuestion(with: self.questions, currentQuestion: previousQuestion)
        }
       
    }
    
    @objc internal func cancelAction(){
        self.navigationController?.popViewController(animated: false)
        self.stop()
    }
}

extension QuestionnaireCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if viewController is QuestionVC {
            
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
                let cancelBtn = UIBarButtonItem(title: Str.cancel, style:UIBarButtonItem.Style.plain, target: self, action: #selector(cancelAction))
                viewController.navigationItem.setRightBarButton(cancelBtn, animated: true)
            }
            
        }
    }
    
}

extension QuestionnaireCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("dismiss")

        stop()
    }
}
