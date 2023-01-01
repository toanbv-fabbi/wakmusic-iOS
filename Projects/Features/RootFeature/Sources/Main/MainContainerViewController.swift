//
//  MainContainerViewController.swift
//  RootFeature
//
//  Created by KTH on 2023/01/02.
//  Copyright © 2023 yongbeomkwak. All rights reserved.
//

import UIKit
import Utility
import DesignSystem

class MainContainerViewController: UIViewController, ViewControllerFromStoryBoard {

    @IBOutlet weak var tabBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var panelViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var panelViewHeightConstraint: NSLayoutConstraint!

    var originalPanelAlpha: CGFloat = 0
    var originalPanelPosition: CGFloat = 0
    var lastPoint: CGPoint = .zero

    lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(panGesture(_:)))
        self.panelView.addGestureRecognizer(gesture)
        return gesture
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    public static func viewController() -> MainContainerViewController {
        let viewController = MainContainerViewController.viewController(storyBoardName: "Main", bundle: Bundle.module)
        return viewController
    }
}

extension MainContainerViewController {

    @objc
    func panGesture(_ gestureRecognizer: UIPanGestureRecognizer) {

        let point = gestureRecognizer.location(in: self.view)
        let direction = gestureRecognizer.direction(in: self.view)
//        let velocity = gestureRecognizer.velocity(in: self.view)

        let window: UIWindow? = UIApplication.shared.windows.first
        let safeAreaInsetsTop: CGFloat = window?.safeAreaInsets.top ?? 0
        let safeAreaInsetsBottom: CGFloat = window?.safeAreaInsets.bottom ?? 0
        var statusBarHeight: CGFloat = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

        if safeAreaInsetsTop > statusBarHeight {
            statusBarHeight = safeAreaInsetsTop
        }

        let tabBarHeight: CGFloat = 49.0
        let screenHeight = APP_HEIGHT() - (statusBarHeight + safeAreaInsetsBottom + tabBarHeight)
        let centerRatio = (-panelViewTopConstraint.constant + originalPanelPosition) /
                            (screenHeight + originalPanelPosition)

        switch gestureRecognizer.state {

        case .began:
            return

        case .changed:
            let yDelta = point.y - lastPoint.y

            var newConstant = panelViewTopConstraint.constant + yDelta
            newConstant = newConstant > originalPanelPosition ? originalPanelPosition : newConstant
            newConstant = newConstant < -screenHeight ? -screenHeight : newConstant

            self.panelViewTopConstraint.constant = newConstant

        case .ended:
            let standard: CGFloat = direction.contains(.Down) ? 1.0 : direction.contains(.Up) ? 0.0 : 0.5
            self.panelViewTopConstraint.constant = (centerRatio < standard) ? self.originalPanelPosition : -screenHeight

            UIView.animate(withDuration: 0.35,
                           delay: 0.0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.8,
                           options: [.curveEaseInOut],
                           animations: {
                self.view.layoutIfNeeded()

            }, completion: { _ in

            })

        default:
            return
        }

        self.lastPoint = point
    }

    private func configureUI() {

        self.navigationController?.setNavigationBarHidden(true, animated: false)

        let viewController = MainTabBarController.viewController()
        self.addChild(viewController)
        viewController.didMove(toParent: self)

        _ = panGestureRecognizer

        self.originalPanelPosition = self.panelViewTopConstraint.constant // -56
        self.originalPanelAlpha = self.panelView.alpha
        self.panelView.isHidden = false
        self.view.layoutIfNeeded()
    }
}
