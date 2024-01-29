import UIKit

class AlertPresenter {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
    
    func requestAlert(alertModel: AlertModel) {
        
        let alert = UIAlertController(title: alertModel.title,
                                      message: alertModel.message,
                                      preferredStyle: .alert)
        alert.view.accessibilityIdentifier = alertModel.id
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }
        alert.addAction(action)
        
        if let viewController {
            viewController.present(alert, animated: true)
        }
    }
    
}

