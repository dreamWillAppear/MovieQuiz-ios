import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    // MARK: - Private Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?

    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            show(quiz: convert(model: firstQuestion))
        }
    }
    
    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
      //отладочное  print(currentQuestion.correctAnswer, currentQuestion.image.description)
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
     //отладочное   print(currentQuestion.correctAnswer, currentQuestion.image.description)
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: ("\(currentQuestionIndex + 1)/\(questionsAmount)"))
        
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel){
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        imageView.layer.borderColor = UIColor.clear.cgColor
        disableButtons(false)
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            guard let currentQuestion = currentQuestion else { return }
            show(quiz: convert(model: currentQuestion))
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    private func showNextQuestionOrResults() {
        guard let nextQuestion = questionFactory.requestNextQuestion() else { return }
        currentQuestion = nextQuestion
        if currentQuestionIndex == questionsAmount - 1 {
            show(quiz: .init(
                title:  "Этот раунд окончен!",
                text: correctAnswers == questionsAmount ?
                "Поздравляем, вы ответили на \(questionsAmount) из \(questionsAmount)!" :
                "Вы ответили на \(correctAnswers) из \(questionsAmount), попробуйте ещё раз!",
                buttonText: "Сыграть ещё раз"))
        } else {
            currentQuestionIndex += 1
            show(quiz: convert(model: nextQuestion))
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        disableButtons(true)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        if isCorrect { correctAnswers += 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            showNextQuestionOrResults()
        }
    }
    
    private func disableButtons(_ mustdisabled: Bool){
        if mustdisabled {
            noButton.isEnabled = false
            yesButton.isEnabled = false
        } else {
            noButton.isEnabled = true
            yesButton.isEnabled = true
        }
    }
    
}
