import UIKit

class MovieQuizPresenter {
    
    // MARK: - Public Properties
    internal weak var viewController: MovieQuizViewController?
    internal let questionsAmount = 10
    internal var currentQuestion: QuizQuestion?
    
    // MARK: - IBOutlet
    // MARK: - Private Properties
    private var currentQuestionIndex = 0
    
    // MARK: - Public Methods
    internal func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    internal func noButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    internal func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: ("\(currentQuestionIndex + 1)/\(questionsAmount)"))
        return questionStep
    }
    
    internal func isLastGame() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    internal func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    internal func resetQuestionIndex() {
        currentQuestionIndex = 0 
    }
    
    // MARK: - IBAction
    // MARK: - Private Methods
}
