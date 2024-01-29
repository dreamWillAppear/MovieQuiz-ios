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
    private var questionFactory: QuestionFactoryProtocol?
    private var alert: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    var correctAnswers = 0
  //  private var alertPresenter = AlertPresenter()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        imageView.layer.cornerRadius = 20
        alert = AlertPresenter(viewController: self)
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - Public Methods
    internal func show(quiz step: QuizStepViewModel){
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        imageView.layer.borderColor = UIColor.clear.cgColor
        disableButtons(false)
    }
    
    internal  func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultMessage()
        
        let alertId = "GameResult"
        let alertModel = AlertModel(title: result.title,
                                    message: message,
                                    buttonText: result.buttonText,
                                    id: alertId)
        { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        alert?.requestAlert(alertModel: alertModel)
    }
        
    internal func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Private Methods
    private func showNextQuestionOrResults() {
        
        guard let gamesCount = statisticService?.gamesCount,
              let bestGameCorrect = statisticService?.bestGame.correct,
              let bestGameTotal = statisticService?.bestGame.total,
              let bestGameDate = statisticService?.bestGame.date.dateTimeString,
              let totalAccuracy = statisticService?.totalAccuracy
        else {
            return
        }
        
        if presenter.isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
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
                alert.requestAlert(alertModel: AlertModel(title: title, message: message, buttonText: buttonText, id: id, completion: presenter.restartGame))
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
        presenter.didAnswer(isCorrect: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
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
            self.presenter.restartGame()
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
