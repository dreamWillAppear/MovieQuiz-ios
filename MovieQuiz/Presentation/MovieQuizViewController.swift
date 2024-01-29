import UIKit

final class MovieQuizViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
    private var alert: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
        alert = AlertPresenter(viewController: self)
        statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
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
            statisticService?.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
            statisticService?.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
            let title = "Этот раунд окончен!"
            let message = """
            Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)
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
            presenter.questionFactory?.requestNextQuestion()
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
    
    internal func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    internal func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    internal func showNetworkError(message: String) {
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

}
