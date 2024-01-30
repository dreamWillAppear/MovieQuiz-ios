import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
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
        alert = AlertPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
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
    
    internal func highlightImageBorder(isCorrect isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
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
    
    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        disableButtons(true)
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        disableButtons(true)
        presenter.noButtonClicked()
    }
    
    // MARK: - Private Methods
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
