import SwiftUI

public protocol SnapshotCreator {
    func makeSnapshot() -> UIImage
}

public class DefaultSnapshotCreator: SnapshotCreator {

    public init() { }

    public func makeSnapshot() -> UIImage {
        guard let uiView: UIView = topVC()?.view else {
            return UIImage()
        }
        return makeSnapshot(from: uiView)
    }

    func makeSnapshot(from view: UIView) -> UIImage {
        let currentSnapshot: UIImage?
        UIGraphicsBeginImageContext(view.frame.size)
        if let currentGraphicsContext = UIGraphicsGetCurrentContext() {
            view.layer.render(in: currentGraphicsContext)
            currentSnapshot = UIGraphicsGetImageFromCurrentImageContext()
        } else {
            currentSnapshot = UIImage()
        }
        UIGraphicsEndImageContext()
        return currentSnapshot ?? UIImage()
    }
    
    private func topVC() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            if UIDevice.current.userInterfaceIdiom == .pad {
                let children = topController.children
                if !children.isEmpty {
                    let splitVC = children[0]
                    let sideVCs = splitVC.children
                    if sideVCs.count > 1 {
                        topController = sideVCs[1]
                        return topController
                    }
                }
            }

            return topController
        }

        return nil
    }
}
