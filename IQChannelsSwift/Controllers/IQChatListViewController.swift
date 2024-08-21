import UIKit
import Combine
import SwiftUI

class IQChatListViewController: IQViewController {
    
    // MARK: - PROPERTIES
    private let viewModel: IQChatListViewModel
    
    private let output: IQChannelsManagerListOutput
    
    private lazy var closeButton: UIButton = {
        let btn: UIButton = .init(frame: .init(x: 0, y: 0, width: 24, height: 24))
        btn.setImage(UIImage(name: "xmark")?.withRenderingMode(.alwaysTemplate), for: [])
        btn.tintColor = UIColor(hex: "242729")
        btn.imageView?.contentMode = .scaleAspectFit
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.addTarget(self, action: #selector(onTapClose), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - INIT
    init(viewModel: IQChatListViewModel,
         output: IQChannelsManagerListOutput) {
        self.viewModel = viewModel
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LIFECYCLE
    override func setupSwiftUI() {
        let hostView: ChatListView = .init(viewModel: viewModel, output: output)
        let controller: UIHostingController = .init(rootView: hostView)
        setupConstructedSwiftUI(interactor: controller)
    }
    
    override func setupNavBar() {
        navigationItem.rightBarButtonItem = .init(customView: closeButton)
    }
    
    override func bindViewModel() {
        viewModel.chatToPresentListener
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] controller in
                navigationController?.pushViewController(controller, animated: true)
            }.store(in: &subscriptions)
        
        viewModel.dismissListener
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                dismiss(animated: true)
            }.store(in: &subscriptions)
        
        viewModel.popListener
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                navigationController?.popViewController(animated: true)
            }.store(in: &subscriptions)
    }
    
    // MARK: - ACTIONS
    @objc
    private func onTapClose() {
        output.listControllerDismissChat()
//        dismiss(animated: true)
    }
}
