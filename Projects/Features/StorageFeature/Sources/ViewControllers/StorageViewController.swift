import UIKit
import SignInFeature
import Utility
import DesignSystem
import RxCocoa
import RxRelay
import RxSwift
import BaseFeature

public final class StorageViewController: BaseViewController, ViewControllerFromStoryBoard,ContainerViewType {
    
    @IBOutlet weak public var contentView: UIView!
    
    
    
    var isLogin:BehaviorRelay<Bool> = BehaviorRelay(value:false)
    
    var signInComponent:SignInComponent!
    
    lazy var bfLoginView = signInComponent.makeView()
    lazy var afLoginView = AfterLoginViewController.viewController()
    let disposeBag = DisposeBag()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureUI()
        
        
        
        
    }

    public static func viewController(signInComponent:SignInComponent) -> StorageViewController {
        let viewController = StorageViewController.viewController(storyBoardName: "Storage", bundle: Bundle.module)
        
        viewController.signInComponent = signInComponent
        
        return viewController
    }
}


extension StorageViewController{
    
    private func configureUI() {
        bindSubView()
    }
    
    private func bindSubView()
    {
        
        isLogin.subscribe { [weak self] (login:Bool) in
            
            guard let self = self else{
                return
            }
            
            if login
            {
                self.add(asChildViewController: self.afLoginView)
            }
            else
            {
                
                self.add(asChildViewController:self.bfLoginView)
            }
            
            
            
        }.disposed(by: disposeBag)
        
        
    }
    
}
