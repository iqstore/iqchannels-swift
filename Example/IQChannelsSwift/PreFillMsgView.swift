//
//  PreFillMsgView.swift
//  IQChannelsSwift
//
//  Created by Mikhail Zinkov on 18.01.2025.
//

import UIKit
import SwiftUI
import PhotosUI
import SafariServices
import IQChannelsSwift

class PreFillMsgView: UIViewController {
//    private var selectedFiles: [String] = []
    private var selectedFiles: [DataFile] = []
    var configuration: IQLibraryConfigurationProtocol?
    var setServer: ((IQPreFillMessages?) -> Void)?
    
    
    private lazy var messageField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.placeholder = "message"
        field.text = "test message"
        field.addToolbar()
        return field
    }()
    
    private lazy var chooseFiles: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.setTitle("Выбрать файлы", for: .normal)
        button.addTarget(self, action: #selector(showAttachChooser), for: .touchUpInside)
        return button
    }()
    
    private lazy var selectedFilesLabel: UILabel = {
        let label = UILabel()
        label.text = "Выбранные файлы:"
        label.textColor = .black

        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var sendMsg: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.setTitle("Отправить", for: .normal)
        button.addTarget(self, action: #selector(openChat), for: .touchUpInside)
        return button
    }()
    
    
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            messageField, chooseFiles, selectedFilesLabel, sendMsg
        ])
        view.spacing = 16
        view.distribution = .fillEqually
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDismissKeyboardOnTap()
        view.addSubview(stackView)
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageField.heightAnchor.constraint(equalToConstant: 62),
        ])
    }

    private func setDismissKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    
    
    
    @objc private func openChat() {
        let textMsg = messageField.text ?? ""
        print("showChat called with message: \(textMsg) \nfiles: \(selectedFiles)")
        
        let preFillMessages = IQPreFillMessages(textMsg: [textMsg], fileMsg: selectedFiles)
        
        setServer?(preFillMessages)
        
        configuration?.login(.anonymous)
        if let navigationController = configuration?.getViewController() {
            present(navigationController, animated: true)
        }
    }
    
    
    

    @objc private func showAttachChooser() {
        displayAttachmentOptions()
    }

    
    
    
    
    
    
    
    
    
    private func displayAttachmentOptions() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "Галерея", style: .default, handler: { _ in
            self.photoSourceDidTap(source: .photoLibrary)
        }))
        alert.addAction(.init(title: "Файл", style: .default, handler: { _ in
            self.fileSourceDidTap()
        }))
        alert.addAction(.init(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    private func photoSourceDidTap(source: UIImagePickerController.SourceType){
        switch source {
        case .photoLibrary, .savedPhotosAlbum:
            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            configuration.selectionLimit = 10
            configuration.preferredAssetRepresentationMode = .current
            configuration.filter = PHPickerFilter.images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true)
        case .camera:
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true)
        @unknown default: break
        }
    }
    
    private func fileSourceDidTap(){
        let documentController = UIDocumentPickerViewController(forOpeningContentTypes: [.data])
        documentController.delegate = self
        documentController.allowsMultipleSelection = true
        documentController.modalPresentationStyle = .formSheet
        present(documentController, animated: true)
    }
    
    
    
    
    
    
    private func sendFiles(items: [(URL?, UIImage?)]) {
        selectedFiles = items.prefix(10).compactMap { (url, image) -> DataFile? in
            if let url {
                defer { url.stopAccessingSecurityScopedResource() }
                guard url.startAccessingSecurityScopedResource(), let data = try? Data(contentsOf: url) else { return nil }
                return .init(data: data, filename: url.lastPathComponent)
            } else if let image {
                guard let data = image.dataRepresentation(withMaxSizeMB: CGFloat(30)) else { return nil }
                return .init(data: data, filename: "image.jpeg")
            }
            return nil
        }
        updateSelectedFilesLabel()
    }

    private func sendImages(result: [PHPickerResult]) {
        Task {
            for item in result {
                guard let data = await item.data(maxSizeInMB: CGFloat(30)) else { continue }
                let isGif = item.itemProvider.hasItemConformingToTypeIdentifier(UTType.gif.identifier)
                selectedFiles.append(.init(data: data, filename: isGif ? "image.gif" : "image.jpeg"))
            }
        }
        updateSelectedFilesLabel()
    }

    private func updateSelectedFilesLabel() {
        let filesText = selectedFiles.map { $0.filename }.joined(separator: ";\n")
        selectedFilesLabel.text = "Выбранные файлы:\n\(filesText)"
    }
}





// MARK: - PH PICKER DELEGATE
extension PreFillMsgView: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        sendImages(result: results)
    }
}

// MARK: - IMAGE PICKER DELEGATE
extension PreFillMsgView: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let url = info[.imageURL] as? URL { //123123
            sendFiles(items: [(url, nil)])
        } else if let image = info[.editedImage] as? UIImage {
            sendFiles(items: [(nil, image)])
        }
    }
}

// MARK: - DOCUMENT PICKER DELEGATE
extension PreFillMsgView: UIDocumentPickerDelegate & UINavigationControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true)
        sendFiles(items: urls.map { ($0, nil) })
        
    }
}




