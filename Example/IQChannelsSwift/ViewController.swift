//
//  ViewController.swift
//  IQChannelsSwift
//
//  Created by Daulet Tokmukhanbet on 05/05/2024.
//  Copyright (c) 2024 Daulet Tokmukhanbet. All rights reserved.
//

import UIKit
import IQChannelsSwift

class ViewController: UIViewController, UITextFieldDelegate, IQChannelsUnreadListenerProtocol {
    var id: String {
        UUID().uuidString
    }
    func iqChannelsUnreadDidChange(_ unread: Int) {
        DispatchQueue.main.async {
            self.unreadLabel.text = "Непрочитанных сообщений: \(unread)"
        }
    }
    
    
    
    private lazy var serverField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.placeholder = "server"
        field.addToolbar()
        return field
    }()
    
    private lazy var emailField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.text = "101"
        field.addToolbar()
        return field
    }()
    
    private lazy var channelsField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.text = "support"
        field.addToolbar()
        return field
    }()
    
    private lazy var unreadLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.layer.cornerRadius = 12
        label.text = "Непрочитанных сообщений: nil"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var styleButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.setTitle("Загрузить стили", for: .normal)
        button.addTarget(self, action: #selector(styleDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var styleDark: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.setTitle("Выбрать темный стиль", for: .normal)
        button.addTarget(self, action: #selector(styleDarkTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var styleLight: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.setTitle("Выбрать светлый стиль", for: .normal)
        button.addTarget(self, action: #selector(styleLightTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var styleSystem: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.setTitle("Выбрать системный стиль", for: .normal)
        button.addTarget(self, action: #selector(styleSystemTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.setTitle("Войти", for: .normal)
        button.addTarget(self, action: #selector(loginDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var anonButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.setTitle("Анонимный чат", for: .normal)
        button.addTarget(self, action: #selector(anonymousDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var preFilledMsgButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.setTitle("Предзаполненные сообщения", for: .normal)
        button.addTarget(self, action: #selector(preFilledMsgDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            serverField, emailField, channelsField, unreadLabel, loginButton, anonButton, preFilledMsgButton, styleButton, styleDark, styleLight, styleSystem
        ])
        view.spacing = 16
        view.distribution = .fillEqually
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let configuration: IQLibraryConfigurationProtocol = IQLibraryConfiguration()
    
    var selectedStyle: Data?
    var preFillMessages: IQPreFillMessages?
    
    var serverString = ""
    var channelsArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDismissKeyboardOnTap()
        view.addSubview(stackView)
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        emailField.delegate = self
        
        setServer(server: "https://iqchannels.isimplelab.com")
        
        configuration.login(.anonymous)
        configuration.addUnread(listener: self)
    }

    func setServer(server: String?) {
        serverString = (server?.isEmpty ?? true) ? "" : (server ?? "")
        channelsArray = channelsField.text?.components(separatedBy: .whitespaces) ?? []
        let config = IQChannelsConfig(address: serverString,
                                      channels: channelsArray,
                                      styleJson: selectedStyle,
                                      preFillMessages: preFillMessages)
        preFillMessages = nil
        let headers = ["User-Agent": "MyAgent"]
        configuration.configure(config)
        configuration.setCustomHeaders(headers)
        serverField.text = server
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField === emailField else { return true }
        
        configuration.login(.credentials(textField.text ?? ""))
        showMessages()
        return true
    }
    
    func showMessages(){
        if let navigationController = configuration.getViewController() {
            present(navigationController, animated: true)
        }
    }
    
    @objc func styleDidTap(){
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        picker.allowsMultipleSelection = false
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func styleDarkTap() {
        if selectedStyle == nil {
            showAlert(title: "Ошибка", message: "Сначала установите стили через кнопку \"Загрузить стили\"")
            return
        }
        configuration.setTheme(.dark)
        showAlert(title: "", message: "Установлена темная тема")
    }
    
    @objc func styleLightTap() {
        if selectedStyle == nil {
            showAlert(title: "Ошибка", message: "Сначала установите стили через кнопку \"Загрузить стили\"")
            return
        }
        configuration.setTheme(.light)
        showAlert(title: "", message: "Установлена светлая тема")
    }
    
    @objc func styleSystemTap() {
        if selectedStyle == nil {
            showAlert(title: "Ошибка", message: "Сначала установите стили через кнопку \"Загрузить стили\"")
            return
        }
        configuration.setTheme(.system)
        showAlert(title: "", message: "Установлена системная тема")
    }
    
    @objc func loginDidTap() {
        setServer(server: serverField.text)
        configuration.login(.credentials(emailField.text ?? ""))
        configuration.addUnread(listener: self)
        showMessages()
    }
    
    @objc func anonymousDidTap() {
        showMessages()
    }
    
    @objc func preFilledMsgDidTap() {
        let preFillMsgView = PreFillMsgView()
        preFillMsgView.configuration = configuration
        
        preFillMsgView.setServer = { [weak self] preFillMessages in
            self?.preFillMessages = preFillMessages
            self?.setServer(server: self?.serverField.text)
        }
        
        navigationController?.pushViewController(preFillMsgView, animated: true)
    }
    
    private func setDismissKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func showAlert(title: String, message: String) {
        let alert: UIAlertController = .init(title: title,
                                             message: message,
                                             preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension ViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true)
        guard let url = urls.first,
              url.startAccessingSecurityScopedResource() else { return }
        
        selectedStyle = try? Data(contentsOf: url)
        url.stopAccessingSecurityScopedResource()
    }
}


extension UITextField {
    func addToolbar(withDismissText text: String = "Готово"){
        let toolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: text, style: .done,
                                         target: self, action: #selector(endEditing))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        inputAccessoryView = toolbar
    }
}
