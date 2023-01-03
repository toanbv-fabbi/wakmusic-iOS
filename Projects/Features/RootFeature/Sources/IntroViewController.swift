import UIKit
import Utility
import DesignSystem
import MainTabFeature

open class IntroViewController: UIViewController, ViewControllerFromStoryBoard {

    @IBOutlet weak var logoImageView: UIImageView!

    open override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()

        // Intro 화면에서는 앱에 대한 기본 정보를 받아오는 일을 보통 하는데, 없어서 딜레이 조금 주고 뭔가 하는척 해봤습니다.
        self.perform(#selector(self.showTabBar), with: nil, afterDelay: 1.0)
    }

    public static func viewController() -> IntroViewController {
        let viewController = IntroViewController.viewController(storyBoardName: "Intro", bundle: Bundle.module)
        return viewController
    }
}

extension IntroViewController {

    @objc
    private func showTabBar() {
        let viewController = MainContainerViewController.viewController()
        self.navigationController?.pushViewController(viewController, animated: false)
    }

    private func configureUI() {
        logoImageView.image = DesignSystemAsset.Logo.splash.image
    }
}
