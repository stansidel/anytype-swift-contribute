import Foundation
import SwiftUI


// Workaround for ios 18
// .preferredColorScheme(nil) do not discard preferences to default -> always darkmode when login from darkmode auth flow
final class AppInterfaceStyle {
    
    private weak var window: UIWindow?
    private(set) var defaultStyle: UIUserInterfaceStyle
    private var defaultStyleOverride: UIUserInterfaceStyle?
    
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    
    init(window: UIWindow?) {
        self.window = window
        self.defaultStyle = Container.shared.userDefaultsStorage().userInterfaceStyle
    }
    
    func setDefaultStyle(_ style: UIUserInterfaceStyle) {
        defaultStyle = style
        userDefaults.userInterfaceStyle = style
        updateUserInterfaceStyle()
    }
    
    func overrideDefaultStyle(_ style: UIUserInterfaceStyle?) {
        defaultStyleOverride = style
        updateUserInterfaceStyle()
    }
    
    private func updateUserInterfaceStyle() {
        if let defaultStyleOverride {
            window?.overrideUserInterfaceStyle = defaultStyleOverride
            return
        }
        
        window?.overrideUserInterfaceStyle = defaultStyle
    }
}

struct AppInterfaceStyleKey: EnvironmentKey {
    static let defaultValue = AppInterfaceStyle(window: nil)
}

extension EnvironmentValues {
    var appInterfaceStyle: AppInterfaceStyle {
        get { self[AppInterfaceStyleKey.self] }
        set { self[AppInterfaceStyleKey.self] = newValue }
    }
}

extension View {
    func setAppInterfaceStyleEnv(window: UIWindow?) -> some View {
        environment(\.appInterfaceStyle, AppInterfaceStyle(window: window))
    }
}
