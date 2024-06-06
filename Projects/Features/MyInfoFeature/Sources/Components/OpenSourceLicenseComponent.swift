import Foundation
import UIKit
import NeedleFoundation
import MyInfoFeatureInterface

public protocol OpenSourceLicenseDependency: Dependency {}

public final class OpenSourceLicenseComponent: Component<OpenSourceLicenseDependency>, OpenSourceLicenseFactory {
    public func makeView() -> UIViewController {
        return OpenSourceLicenseViewController.viewController(
            viewModel: OpenSourceLicenseViewModel()
        )
    }
}
