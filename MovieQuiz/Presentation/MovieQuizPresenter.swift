import UIKit

class MovieQuizPresenter/*: QuestionFactoryDelegate*/ {
    
    // MARK: - Public Properties
    internal weak var viewController: MovieQuizViewController?
    internal let questionsAmount = 10
    internal var currentQuestion: QuizQuestion?
    internal var correctAnswers = 0
    // MARK: - IBOutlet
    // MARK: - Private Properties
    private var currentQuestionIndex = 0
    var questionFactory: QuestionFactoryProtocol?
    
    // MARK: - Public Methods
    internal func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    internal func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    internal func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: ("\(currentQuestionIndex + 1)/\(questionsAmount)"))
        return questionStep
    }
    
    internal func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    internal func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    internal func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    internal func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    internal func showNextQuestionOrResults() {
           if self.isLastQuestion() {
               let text = "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
               
               let viewModel = QuizResultsViewModel(
                   title: "Этот раунд окончен!",
                   text: text,
                   buttonText: "Сыграть ещё раз")
                   viewController?.show(quiz: viewModel)
           } else {
               self.switchToNextQuestion()
               questionFactory?.requestNextQuestion()
           }
       }
    
    internal func didAnswer(isCorrect: Bool) {
        if (isCorrect) { correctAnswers += 1 }
    }

    // MARK: - IBAction
    // MARK: - Private Methods
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
}
