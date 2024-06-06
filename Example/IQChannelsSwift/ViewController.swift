//
//  ViewController.swift
//  IQChannelsSwift
//
//  Created by Daulet Tokmukhanbet on 05/05/2024.
//  Copyright (c) 2024 Daulet Tokmukhanbet. All rights reserved.
//

import UIKit
import IQChannelsSwift

class ViewController: UIViewController, UITextFieldDelegate {
    
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
        field.text = "support finance"
        field.addToolbar()
        return field
    }()
    
    private lazy var styleButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.setTitle("Выбрать стиль", for: .normal)
        button.addTarget(self, action: #selector(styleDidTap), for: .touchUpInside)
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
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            serverField, emailField, channelsField, loginButton, anonButton, styleButton
        ])
        view.spacing = 16
        view.distribution = .fillEqually
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let configuration: IQLibraryConfigurationProtocol = IQLibraryConfiguration()
    
    var selectedStyle: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDismissKeyboardOnTap()
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        emailField.delegate = self
        setServer(server: "https://sandbox.iqstore.ru/")
    }

    func setServer(server: String?) {
        let server = (server?.isEmpty ?? true) ? "https://sandbox.iqstore.ru/" : (server ?? "")
        let channels = channelsField.text?.components(separatedBy: .whitespaces) ?? []
        let config = IQChannelsConfig(address: server,
                                      channels: channels,
                                      styleJson: selectedStyle)
        let headers = ["User-Agent": "MyAgent"]
        configuration.configure(config)
        configuration.setCustomHeaders(headers)
        serverField.text = server
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField === emailField else { return true }
        
        loginWithEmail(textField.text)
        return true
    }
    
    func loginWithEmail(_ email: String?) {
        configuration.login(.credentials(email ?? ""))
        showMessages()
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
    
    @objc func loginDidTap() {
        setServer(server: serverField.text)
        loginWithEmail(emailField.text)
    }
    
    @objc func anonymousDidTap() {
        setServer(server: serverField.text)
        configuration.login(.anonymous)
        showMessages()
    }
    
    private func setDismissKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
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
