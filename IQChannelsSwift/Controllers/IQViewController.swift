import UIKit
import Combine

public class IQViewController: UIViewController {
    
    // MARK: - PROPERTIES
    var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - LIFECYCLE
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        setupSwiftUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setupNavBar()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setupNavBar() {}
    func setupView() {}
    func bindViewModel() {}
    func setupSwiftUI() {}
    
    // MARK: - METHODS
    func setupConstructedSwiftUI(interactor: UIViewController) {
        addChild(interactor)
        view.addSubview(interactor.view)
        
        interactor.view.translatesAutoresizingMaskIntoConstraints = false
        interactor.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        interactor.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        interactor.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        interactor.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
}
