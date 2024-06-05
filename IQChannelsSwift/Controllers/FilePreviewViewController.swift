//
//  FilePreviewViewController.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 05.06.2024.
//

import UIKit
import WebKit
import MobileCoreServices
import UniformTypeIdentifiers

class FilePreviewController: UIViewController, WKNavigationDelegate, URLSessionDelegate {
    
    private var webView: WKWebView!
    private var documentUrl: URL
    private var downloadButton: UIButton!
    private var dismissButton: UIButton!
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    // Initialize with a URL
    init(url: URL) {
        self.documentUrl = url
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the web view
        setupWebView()
        
        // Setup the download button
        setupDownloadButton()
    }
    
    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        let request = URLRequest(url: documentUrl)
        webView.load(request)
    }
    
    private func setupDownloadButton() {
        dismissButton = UIButton(type: .system)
        dismissButton.setImage(.init(systemName: "xmark.circle"), for: .normal)
        dismissButton.tintColor = .white
        dismissButton.backgroundColor = .gray.withAlphaComponent(0.8)
        dismissButton.layer.cornerRadius = 20
        dismissButton.clipsToBounds = true
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dismissButton)

        downloadButton = UIButton(type: .system)
        downloadButton.setImage(UIImage(systemName: "arrow.down.circle"), for: .normal)
        downloadButton.tintColor = .white
        downloadButton.backgroundColor = .gray.withAlphaComponent(0.8)
        downloadButton.layer.cornerRadius = 20
        downloadButton.clipsToBounds = true
        downloadButton.addTarget(self, action: #selector(downloadDocument), for: .touchUpInside)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(downloadButton)
        
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dismissButton.heightAnchor.constraint(equalToConstant: 40),
            dismissButton.widthAnchor.constraint(equalToConstant: 40),
        ])
        
        NSLayoutConstraint.activate([
            downloadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            downloadButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            downloadButton.heightAnchor.constraint(equalToConstant: 40),
            downloadButton.widthAnchor.constraint(equalToConstant: 40),
        ])

    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            return completionHandler(URLSession.AuthChallengeDisposition.useCredential, nil)
        }
        return completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            return completionHandler(URLSession.AuthChallengeDisposition.useCredential, nil)
        }
        return completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
    }
    
    @objc private func dismissButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func downloadDocument() {
        // Assuming the document is not protected by copyright or other restrictions
        let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        let downloadTask = session.downloadTask(with: documentUrl) { [weak self] url, response, error in
            guard let self, let url, let data = try? Data(contentsOf: url), error == nil else {
                self?.showAlert(message: "Не удалось загрузить файл")
                return
            }
            
            let type: UTType = .init(self.documentUrl.lastPathComponent) ?? .data
            let savedURL = documentsDirectory.appendingPathComponent(response?.suggestedFilename ?? "downloadedFile", conformingTo: type)
            FileManager.default.createFile(atPath: savedURL.path, contents: data)
            
            DispatchQueue.main.async {
                self.present(UIActivityViewController(activityItems: [savedURL], applicationActivities: nil), animated: true)
            }
        }
        
        downloadTask.resume()
    }
}
