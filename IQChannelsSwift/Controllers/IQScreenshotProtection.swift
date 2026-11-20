//
//  IQScreenshotProtection.swift
//  IQChannelsSwift
//
//  Created by Mikhail Zinkov on 19.11.2026.
//

import UIKit

final class IQScreenshotProtection {

    private let secureField = UITextField()
    private let backdropView = UIView()
    private var shieldView: UIView?
    private weak var protectedView: UIView?
    private var capturedObservation: NSKeyValueObservation?
    private var lifecycleObservers: [NSObjectProtocol] = []
    private var isEngaged = false
    private var isCanvasApplied = false

    init() {
        secureField.isSecureTextEntry = true
        secureField.isUserInteractionEnabled = false
        backdropView.backgroundColor = .black
    }

    func engage(on view: UIView) {
        guard !isEngaged else { return }
        isEngaged = true
        protectedView = view

        installBackdrop()
        observeLifecycle()
        observeCaptureState()
        applyCanvasProtection()
    }

    func disengage() {
        guard isEngaged else { return }
        isEngaged = false

        removeShield()
        backdropView.removeFromSuperview()

        lifecycleObservers.forEach { NotificationCenter.default.removeObserver($0) }
        lifecycleObservers.removeAll()
        capturedObservation?.invalidate()
        capturedObservation = nil
    }

    private func installBackdrop() {
        guard let container = protectedView?.superview ?? protectedView?.window else { return }

        backdropView.translatesAutoresizingMaskIntoConstraints = false
        container.insertSubview(backdropView, at: 0)
        NSLayoutConstraint.activate([
            backdropView.topAnchor.constraint(equalTo: container.topAnchor),
            backdropView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            backdropView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            backdropView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
    }

    private func observeLifecycle() {
        lifecycleObservers.append(
            NotificationCenter.default.addObserver(
                forName: UIApplication.userDidTakeScreenshotNotification,
                object: nil,
                queue: .main
            ) { _ in
                IQLog.debug(message: "ScreenshotProtection: screenshot taken")
            }
        )
    }

    private func observeCaptureState() {
        let screen = protectedView?.window?.screen ?? UIScreen.main
        capturedObservation = screen.observe(\.isCaptured, options: [.initial]) { [weak self] _, change in
            DispatchQueue.main.async {
                self?.updateShield(isCaptured: change.newValue ?? false)
            }
        }
    }

    private func updateShield(isCaptured: Bool) {
        guard isEngaged, let protectedView else { return }

        if isCaptured {
            guard shieldView == nil else { return }

            let shield = UIView()
            shield.backgroundColor = .black
            shield.isUserInteractionEnabled = false
            shield.translatesAutoresizingMaskIntoConstraints = false
            protectedView.addSubview(shield)
            NSLayoutConstraint.activate([
                shield.topAnchor.constraint(equalTo: protectedView.topAnchor),
                shield.bottomAnchor.constraint(equalTo: protectedView.bottomAnchor),
                shield.leadingAnchor.constraint(equalTo: protectedView.leadingAnchor),
                shield.trailingAnchor.constraint(equalTo: protectedView.trailingAnchor)
            ])
            shieldView = shield
        } else {
            removeShield()
        }
    }

    private func removeShield() {
        shieldView?.removeFromSuperview()
        shieldView = nil
    }

    private func applyCanvasProtection(attempt: Int = 0) {
        guard !isCanvasApplied, let view = protectedView, let window = view.window else { return }

        if secureField.superview !== window {
            secureField.frame = window.bounds
            secureField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(secureField)
            secureField.layoutIfNeeded()
        }

        let secureContainer = secureField.subviews.first {
            String(describing: type(of: $0)).contains("CanvasView")
        } ?? secureField.subviews.first

        guard let secureContainer else {
            if attempt < 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.applyCanvasProtection(attempt: attempt + 1)
                }
            } else {
                IQLog.debug(message: "ScreenshotProtection: secure container not found, canvas protection skipped")
            }
            return
        }

        secureContainer.layer.addSublayer(view.layer)
        isCanvasApplied = true
    }

    deinit {
        secureField.removeFromSuperview()
        lifecycleObservers.forEach { NotificationCenter.default.removeObserver($0) }
        capturedObservation?.invalidate()
    }
}
