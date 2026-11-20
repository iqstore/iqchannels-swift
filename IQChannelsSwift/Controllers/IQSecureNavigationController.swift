//
//  IQSecureNavigationController.swift
//  IQChannelsSwift
//
//  Created by Mikhail Zinkov on 19.11.2026.
//

import UIKit

final class IQSecureNavigationController: UINavigationController {

    private let screenshotProtection = IQScreenshotProtection()

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenshotProtection.engage(on: view)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        screenshotProtection.disengage()
    }

    deinit {
        screenshotProtection.disengage()
    }
}
