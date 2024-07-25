import Foundation
import Services
import Combine

protocol ParticipantsSubscriptionProtocol: AnyObject {
    var participantsPublisher: AnyPublisher<[Participant], Never> { get }
}

extension ParticipantsSubscriptionProtocol {
    var activeParticipantsPublisher: AnyPublisher<[Participant], Never> {
        participantsPublisher.map { $0.filter { $0.status == .active } }.eraseToAnyPublisher()
    }
}

actor ParticipantsSubscription: ParticipantsSubscriptionProtocol {
    
    // MARK: - DI
    
    private let subscriptionStorageProvider: any SubscriptionStorageProviderProtocol = Container.shared.subscriptionStorageProvider()
    private let subscriptionStorage: SubscriptionStorageProtocol
    private let subId: String
    let participantsPublisher: AnyPublisher<[Participant], Never>
    
    init(spaceId: String) {
        let subId = "ParticipantsSubscription-\(UUID())-\(spaceId)"
        self.subId = subId
        self.subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subId)
        self.participantsPublisher = subscriptionStorage.statePublisher
            .map { $0.items.compactMap { try? Participant(details: $0) } }
            .eraseToAnyPublisher()
        Task {
            try await startSubscription(spaceId: spaceId)
        }
    }
    
    
    // MARK: - Private
    
    private func startSubscription(spaceId: String) async throws {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilters(includeHiddenDiscovery: false)
            SearchHelper.spaceId(spaceId)
            SearchHelper.layoutFilter([.participant])
            SearchHelper.participantStatusFilter(.active, .joining, .removing)
        }
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subId,
                sorts: [sort],
                filters: filters,
                limit: 0,
                offset: 0,
                keys: Participant.subscriptionKeys.map { $0.rawValue }
            )
        )
        
        try await subscriptionStorage.startOrUpdateSubscription(data: searchData)
    }
}
