import UIKit

extension UIViewController {
    func showAlert(title: String = "Ошибка",
                   message: String){
        let alert: UIAlertController = .init(title: title,
                                             message: message,
                                             preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
}
