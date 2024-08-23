import Foundation

@MainActor
final class WallpaperPickerViewModel: ObservableObject {
 
    private let spaceId: String
    private let userDefaults: UserDefaultsStorageProtocol
    
    @Published var wallpaper: BackgroundType {
        didSet {
            userDefaults.setWallpaper(spaceId: spaceId, wallpaper: wallpaper)
        }
    }
    
    init(spaceId: String) {
        self.spaceId = spaceId
        
        let userDefaults = Container.shared.userDefaultsStorage()
        self.userDefaults = userDefaults
        wallpaper = userDefaults.wallpaper(spaceId: spaceId)
    }
}
