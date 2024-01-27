import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var presenter = MovieQuizPresenter()
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alert: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
           super.viewDidLoad()
           presenter.viewController = self
           imageView.layer.cornerRadius = 20
           alert = AlertPresenter(viewContoller: self)
           statisticService = StatisticServiceImplementation()
           questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
           showLoadingIndicator()
           questionFactory?.loadData()
        
       }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    // MARK: - Private Methods
    private func show(quiz step: QuizStepViewModel){
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        imageView.layer.borderColor = UIColor.clear.cgColor
        disableButtons(false)
    }
    
    private func restart() {
        presenter.resetQuestionIndex()
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    
    private func showNextQuestionOrResults() {
        
        guard let gamesCount = statisticService?.gamesCount,
              let bestGameCorrect = statisticService?.bestGame.correct,
              let bestGameTotal = statisticService?.bestGame.total,
              let bestGameDate = statisticService?.bestGame.date.dateTimeString,
              let totalAccuracy = statisticService?.totalAccuracy
        else {
            return
        }
        if presenter.isLastGame() {
            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
            let title = "Этот раунд окончен!"
            let message = """
            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(bestGameCorrect)/\(bestGameTotal) (\(bestGameDate))
            Средняя точноcть: \(String(format: "%.2f", totalAccuracy))%
            """
            let buttonText = "Сыграть ещё раз"
            let id = "AlertGameResult"
            if let alert {
                alert.requestAlert(alertModel: AlertModel(title: title, message: message, buttonText: buttonText, id: id, completion: restart))
            }
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    internal func showAnswerResult(isCorrect: Bool) {
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
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз", 
                               id: "FailedAlert") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alert?.requestAlert(alertModel: model)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true 
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
}
