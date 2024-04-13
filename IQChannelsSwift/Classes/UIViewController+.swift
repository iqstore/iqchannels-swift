import UIKit
import SwiftMessages

extension UIViewController {
    
    func showCopyPreviewView() {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.backgroundHeight = 60
        view.configureTheme(backgroundColor: UIColor(hex: 0x57B22F),
                            foregroundColor: .white)
        view.button?.backgroundColor = .clear
        view.button?.tintColor = .white
        view.button?.contentEdgeInsets = .zero
        view.button?.layer.cornerRadius = 0
        view.configureContent(title: nil,
                              body: "Сообщение скопировано",
                              iconImage: UIImage(named: "circleCheckmark",
                                                 in: .channelsAssetBundle(),
                                                 compatibleWith: nil),
                              iconText: nil,
                              buttonImage: UIImage(named: "xmark",
                                                   in: .channelsAssetBundle(),
                                                   with: nil),
                              buttonTitle: nil) { button in
            SwiftMessages.hide()
        }
        
        view.bodyLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        view.configureIcon(withSize: .init(width: 16, height: 16), contentMode: .scaleAspectFill)

        view.configureDropShadow()

        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 12

        SwiftMessages.show(view: view)
    }
}
