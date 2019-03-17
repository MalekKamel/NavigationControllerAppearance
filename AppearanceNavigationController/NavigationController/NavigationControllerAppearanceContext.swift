
import Foundation
import UIKit

public protocol NavigationControllerAppearanceContext: AnyObject where Self:  UIViewController {

    func prefersNavigationControllerBarHidden(navigationController: UINavigationController) -> Bool
    func prefersNavigationControllerToolbarHidden(navigationController: UINavigationController) -> Bool
    func preferredNavigationControllerAppearance(navigationController: UINavigationController) -> Appearance?
    func setNeedsUpdateNavigationControllerAppearance()
}

extension NavigationControllerAppearanceContext {

    func prefersNavigationControllerBarHidden(navigationController: UINavigationController) -> Bool {
        return false
    }

    func prefersNavigationControllerToolbarHidden(navigationController: UINavigationController) -> Bool {
        return true
    }

    func preferredNavigationControllerAppearance(navigationController: UINavigationController) -> Appearance? {
        return nil
    }

    func setNeedsUpdateNavigationControllerAppearance() {
        guard let navigationController = self.navigationController as? AppearanceNavigationController
                else { return }

        navigationController.updateAppearance(for: self)
    }
}
