//
//  IQLoginViewController.swift
//  IQChannelsSwift
//
//  Created by Daulet on 05.04.2024.
//

import UIKit
import IQChannelsSwift

public class LoginViewController: UIViewController, UITextFieldDelegate {
    
    private lazy var serverField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.placeholder = "server"
        return field
    }()
    
    private lazy var emailField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.text = "101"
        return field
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.setTitle("Войти", for: .normal)
        button.addTarget(self, action: #selector(loginDidTap), for: .touchUpInside)
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
            serverField, emailField, loginButton, anonButton
        ])
        view.spacing = 16
        view.distribution = .fillEqually
        view.axis = .vertical
        return view
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        emailField.delegate = self
        loginButton.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
        setServer(server: "https://sandbox.iqstore.ru/")
    }
    
    func setServer(server: String?) {
        let server = (server?.isEmpty ?? true) ? "https://sandbox.iqstore.ru/" : (server ?? "")
        
        let config = IQChannelsConfig(address: server,
                                      channel: "support")
        let headers = ["User-Agent": "MyAgent"]
        IQChannels.configure(config)
        IQChannels.setCustomHeaders(headers)
        serverField.text = server
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField === emailField else { return true }
        
        loginWithEmail(textField.text)
        return true
    }
    
    func loginWithEmail(_ email: String?) {
        IQChannels.login(email ?? "")
        showMessages()
    }
    
    func showMessages(){
        let msg = IQChannelMessagesViewController()
        let nav = UINavigationController(rootViewController: msg)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .coverVertical
        present(nav, animated: true)
    }
    
    @objc func loginDidTap() {
        setServer(server: serverField.text)
        loginWithEmail(emailField.text)
    }
    
    @objc func anonymousDidTap() {
        IQChannels.loginAnonymous()
        showMessages()
    }
    
}
