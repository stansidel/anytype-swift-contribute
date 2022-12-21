import UIKit

extension UINavigationController {
    func modifyBarAppearance(
        _ appearance: UINavigationBarAppearance
    ) {
        navigationBar.compactAppearance = appearance
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = appearance
        }
        navigationBar.barTintColor = UIColor.BackgroundNew.primary
        navigationBar.tintColor = UIColor.BackgroundNew.primary
    }

    func replaceLastViewController(_ viewController: UIViewController, animated: Bool) {
        var childViewControllers = viewControllers
        let _ = childViewControllers.popLast()
        childViewControllers.append(viewController)

        setViewControllers(childViewControllers, animated: animated)
    }
}
