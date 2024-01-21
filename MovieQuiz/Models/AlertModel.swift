import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let id: String
    var completion: () -> Void
}
