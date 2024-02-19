import Services
import AnytypeCore

enum DocumentUpdate: Hashable {
    case general
    case syncStatus(SyncStatus)
    case blocks(blockIds: Set<String>)
    case details(id: String)
    case dataSourceUpdate

    var hasUpdate: Bool {
        switch self {
        case .general, .syncStatus, .details, .dataSourceUpdate:
            return true
        case let .blocks(blockIds):
            return !blockIds.isEmpty
        }
    }
}
