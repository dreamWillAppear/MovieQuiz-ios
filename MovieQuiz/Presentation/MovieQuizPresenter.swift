import UIKit

class MovieQuizPresenter/*: QuestionFactoryDelegate*/ {
    
    // MARK: - Public Properties
    internal weak var viewController: MovieQuizViewController?
    internal let questionsAmount = 10
    internal var currentQuestion: QuizQuestion?
    internal var correctAnswers = 0
    // MARK: - IBOutlet
    // MARK: - Private Properties
     var currentQuestionIndex = 0
    var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    // MARK: - Public Methods
    internal func yesButtonClicked() {
        didAnswer(givenAnswer: true)
    }
    
    internal func noButtonClicked() {
        didAnswer(givenAnswer: false)
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
        if isLastQuestion() {

                  let text = "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
                  
                  let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                       text: text,
                                                       buttonText: "Сыграть ещё раз?")
                  viewController?.show(quiz: viewModel)
              } else {
                  switchToNextQuestion()
                  questionFactory?.requestNextQuestion()
              }
       }
    
    internal func makeResultMessage() -> String {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let message = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total)(\(statisticService.bestGame.date.dateTimeString))
            Среедняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            return message
        }
    
    internal func didAnswer(isCorrect: Bool) {
        if (isCorrect) { correctAnswers += 1 }
    }

    // MARK: - IBAction
    // MARK: - Private Methods
    private func didAnswer(givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
