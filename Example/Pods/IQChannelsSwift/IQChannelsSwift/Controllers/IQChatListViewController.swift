import UIKit
import Combine
import SwiftUI

class IQChatListViewController: IQViewController {
    
    // MARK: - PROPERTIES
    private let viewModel: IQChatListViewModel
    
    private let output: IQChannelsManagerListOutput
    
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
    }
}
