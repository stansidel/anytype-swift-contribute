import Combine
import Services
import AnytypeCore
import ProtobufMessages


@MainActor
protocol SyncStatusStorageProtocol {
    func statusPublisher(spaceId: String) -> AnyPublisher<SyncStatusInfo, Never>
    
    func startSubscription()
    func stopSubscriptionAndClean()
}

@MainActor
final class SyncStatusStorage: SyncStatusStorageProtocol {
    @Published private var _update: SyncStatusInfo?
    private var updatePublisher: AnyPublisher<SyncStatusInfo?, Never> { $_update.eraseToAnyPublisher() }
    private var subscription: AnyCancellable?
    
    private var defaultValues = [String: SyncStatusInfo]()
    
    nonisolated init() { }
    
    func statusPublisher(spaceId: String) -> AnyPublisher<SyncStatusInfo, Never> {
        updatePublisher
            .filter { $0?.id == spaceId}
            .compactMap { $0 }
            .merge(with: Just(defaultValues[spaceId] ?? .default(spaceId: spaceId)))
            .receiveOnMain()
            .eraseToAnyPublisher()
    }
    
    func startSubscription() {
        anytypeAssert(subscription.isNil, "Non nil subscription in SyncStatusStorage")
        subscription = EventBunchSubscribtion.default.addHandler { [weak self] events in
            self?.handle(events: events)
        }
    }
    
    func stopSubscriptionAndClean() {
        anytypeAssert(subscription.isNotNil, "Nil subscription in SyncStatusStorage")
        subscription = nil
        _update = nil
    }
    
    // MARK: - Private
    
    private func handle(events: EventsBunch) {
        for event in events.middlewareEvents {
            switch event.value {
            case .spaceSyncStatusUpdate(let update):
                defaultValues[update.id] = update
                _update = update
            default:
                break
            }
        }
    }
}
