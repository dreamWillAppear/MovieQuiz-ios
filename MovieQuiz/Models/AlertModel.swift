import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var completion: () -> Void
    
}



//кст заголовка алерта title,
//текст сообщения алерта message,
//текст для кнопки алерта buttonText,
//замыкание без параметров для действия по кнопке алерта completion.
