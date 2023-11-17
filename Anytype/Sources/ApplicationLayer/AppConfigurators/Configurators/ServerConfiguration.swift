import Foundation
import ProtobufMessages

final class ServerConfiguration: AppConfiguratorProtocol {
        
    func configure() {
        guard let pathUrl = ServerConfigurationStorage.shared.currentConfigurationPath() else { return }
        EnvironmentStorage.setEnv(key: "ANY_SYNC_NETWORK", value: pathUrl.path)
    }
}
