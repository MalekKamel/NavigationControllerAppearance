
import Foundation
import UIKit

public class AppearanceNavigationController: UINavigationController {
    private var appliedAppearance: Appearance?

    public var appearanceApplyingStrategy = AppearanceApplyingStrategy() {
        didSet {
            apply(appearance: appliedAppearance, animated: false)
        }
    }

    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        delegate = self
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        delegate = self
    }
    
    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        delegate = self
    }
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

}

// MARK: - UINavigationControllerDelegate
extension AppearanceNavigationController: UINavigationControllerDelegate {

    public func navigationController(
            _ navigationController: UINavigationController,
            willShow viewController: UIViewController,
            animated: Bool
    ) {
        applyAppearance(for: viewController, animated: animated)
    }

}

// MARK: appearance implementation
extension AppearanceNavigationController {

    private func applyAppearance(
            for viewController: UIViewController,
            animated: Bool
    ) {
        guard let appearanceContext = viewController as? NavigationControllerAppearanceContext else {
            return
        }

        applyAppearance(for: appearanceContext, animated: animated)

        interactiveGestureAppearance(for: viewController, animated: animated)
    }

    private func interactiveGestureAppearance(
            for viewController: UIViewController,
            animated: Bool
    ) {
        // interactive gesture requires more complex logic.
        guard let coordinator = viewController.transitionCoordinator, coordinator.isInteractive else {
            return
        }

        coordinator.animate(
                alongsideTransition: { _ in },
                completion: { context in
                    if context.isCancelled, let appearanceContext = self.topViewController as? NavigationControllerAppearanceContext {
                        // hiding navigation bar & toolbar within interaction completion will result into inconsistent UI state
                        self.setNavigationBarHidden(
                                appearanceContext.prefersNavigationControllerBarHidden(navigationController: self),
                                animated: animated
                        )
                        self.setToolbarHidden(
                                appearanceContext.prefersNavigationControllerToolbarHidden(navigationController: self),
                                animated: animated
                        )
                    }
                }
        )

        coordinator.notifyWhenInteractionChanges { context in
            let key = UITransitionContextViewControllerKey.from
            if context.isCancelled, let from = context.viewController(forKey: key) as? NavigationControllerAppearanceContext {
                // changing navigation bar & toolbar appearance within animate completion will result into UI glitch
                self.apply(
                        appearance: from.preferredNavigationControllerAppearance(navigationController: self),
                        animated: true
                )
            }
        }
    }

    private func applyAppearance(
            for context: NavigationControllerAppearanceContext,
            animated: Bool
    ) {
        setNavigationBarHidden(
                context.prefersNavigationControllerBarHidden(navigationController: self),
                animated: true
        )
        setToolbarHidden(
                context.prefersNavigationControllerToolbarHidden(navigationController: self),
                animated: true
        )
        apply(
                appearance: context.preferredNavigationControllerAppearance(navigationController: self),
                animated: true
        )
    }

    private func apply(appearance: Appearance?, animated: Bool) {
        guard appearance != nil && appliedAppearance != appearance  else { return }

        appliedAppearance = appearance

        appearanceApplyingStrategy.apply(
                appearance: appearance,
                to: self,
                animated: animated
        )
        setNeedsStatusBarAppearanceUpdate()
    }

    func updateAppearance(for viewController: UIViewController) {
        guard let context = viewController as? NavigationControllerAppearanceContext,
              viewController == topViewController && transitionCoordinator == nil
                else { return }

        applyAppearance(for: context, animated: true)
    }

    public func updateAppearance() {
        guard let top = topViewController else { return }
        updateAppearance(for: top)
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return appliedAppearance?.statusBarStyle ?? super.preferredStatusBarStyle
    }

    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return appliedAppearance != nil ? .fade : super.preferredStatusBarUpdateAnimation
    }
}
