import UIKit
import SDWebImage
import PhotosUI

class PreviewViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - PROPERTIES
    private let url: URL
    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    
    private var data: Data?
    
    // MARK: - INIT
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup ScrollView
        scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .white
        view.addSubview(scrollView)
        
        // Setup ImageView
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        let indicator = SDWebImageActivityIndicator.grayLarge
        imageView.sd_imageIndicator = indicator
        imageView.sd_imageTransition = .fade
        indicator.startAnimatingIndicator()
        SDWebImageManager.shared.loadImage(with: url, progress: nil) { [weak self] image, data, _, _, _, _ in
            indicator.stopAnimatingIndicator()
            self?.imageView.image = image
            
            if let data = data {
                self?.data = data
            } else if let image = image {
                self?.data = image.jpegData(compressionQuality: 100)
            }
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        // Setup Dismiss Button
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(.init(systemName: "xmark.circle"), for: .normal)
        dismissButton.tintColor = .white
        dismissButton.backgroundColor = .gray.withAlphaComponent(0.8)
        dismissButton.layer.cornerRadius = 20
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dismissButton)
        
        // Setup Download Button
        let downloadButton = UIButton(type: .system)
        downloadButton.setImage(.init(systemName: "arrow.down.circle"), for: .normal)
        downloadButton.tintColor = .white
        downloadButton.backgroundColor = .gray.withAlphaComponent(0.8)
        downloadButton.layer.cornerRadius = 20
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
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
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1.0 {
            scrollView.backgroundColor = .black
        } else {
            scrollView.backgroundColor = .white
        }
    }

    // MARK: - ACTIONS
    @objc func dismissButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func downloadButtonTapped() {
        guard let data else { return }
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch authorizationStatus {
        case .authorized, .limited:
            savePhotoToLibrary(data: data)
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                DispatchQueue.main.async {
                    if status == .authorized || status == .limited {
                        self.savePhotoToLibrary(data: data)
                    } else {
                        self.showAccessDeniedAlert()
                    }
                }
            }
            
        case .denied, .restricted:
            showAccessDeniedAlert()
            
        @unknown default:
            break
        }
    }

    private func savePhotoToLibrary(data: Data) {
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: data, options: nil)
        }) { success, error in
            DispatchQueue.main.async {
                let title = success ? IQLanguageTexts.model.photoSavedSuccessTitle ?? "Успешно!": IQLanguageTexts.model.photoSavedErrorTitle ?? "Ошибка!"
                let message = success ? IQLanguageTexts.model.photoSavedSuccessText ?? "Фото успешно сохранено в галерею." : IQLanguageTexts.model.photoSavedErrorText ?? "Не удалось сохранить фото."
                self.showAlert(title: title, message: message)
            }
        }
    }

    private func showAccessDeniedAlert() {
        let alert: UIAlertController = .init(title: IQLanguageTexts.model.galleryPermissionDeniedTitle ?? "Доступ к галерее запрещён",
                                             message: IQLanguageTexts.model.galleryPermissionDeniedText ?? "Пожалуйста, разрешите доступ в настройках, чтобы сохранять фото.",
                                             preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: IQLanguageTexts.model.galleryPermissionAlertCancel ?? "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: IQLanguageTexts.model.galleryPermissionAlertSettings ?? "В настройки", style: .default) { _ in
            if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
            }
        })
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
