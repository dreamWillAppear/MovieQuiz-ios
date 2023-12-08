import UIKit

class AlertPresenter {
    
    private weak var viewContoller: UIViewController?
    
    init(viewContoller: UIViewController? = nil) {
        self.viewContoller = viewContoller
    }
    
    func requestAlert(alertModel: AlertModel) {

        let alert = UIAlertController(title: alertModel.title,
                                      message: alertModel.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }
        alert.addAction(action)
        
        if let viewContoller {
            viewContoller.present(alert, animated: true)
        }
    }
    
}

