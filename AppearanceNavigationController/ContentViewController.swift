
import Foundation
import UIKit

class ContentViewController: UIViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    var appearance: Appearance? {
        didSet {
            setNeedsUpdateNavigationControllerAppearance()
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        setNeedsUpdateNavigationControllerAppearance()
    }

}

extension ContentViewController: NavigationControllerAppearanceContext {

    func prefersNavigationControllerToolbarHidden(navigationController: UINavigationController) -> Bool {
        // hide toolbar during editing
        return isEditing
    }

    func preferredNavigationControllerAppearance(navigationController: UINavigationController) -> Appearance? {
        // inverse navigation bar color and status bar during editing
        return isEditing ? appearance?.inverse() : appearance
    }

}
