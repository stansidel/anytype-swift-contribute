import AnytypeCore
import Services
import ProtobufMessages
import Combine

extension ObjectType: IdProvider {}

enum ObjectTypeError: Error {
    case objectTypeNotFound
}

final class ObjectTypeProvider: ObjectTypeProviderProtocol {
    
    static let shared: ObjectTypeProviderProtocol = ObjectTypeProvider(
        subscriptionsService: ServiceLocator.shared.subscriptionService(),
        subscriptionBuilder: ObjectTypeSubscriptionDataBuilder(accountManager: ServiceLocator.shared.accountManager())
    )
    
    static let subscriptionId = "SubscriptionId.ObjectType"
    
    // MARK: - Private variables
    
    @Published private var defaultObjectTypes: [String: String] = UserDefaultsConfig.defaultObjectTypes {
        didSet {
            UserDefaultsConfig.defaultObjectTypes = defaultObjectTypes
        }
    }
    private let subscriptionsService: SubscriptionsServiceProtocol
    private let subscriptionBuilder: ObjectTypeSubscriptionDataBuilderProtocol
    
    private(set) var objectTypes = [ObjectType]()
    private var searchTypesById = SynchronizedDictionary<String, ObjectType>()
    
    private init(
        subscriptionsService: SubscriptionsServiceProtocol,
        subscriptionBuilder: ObjectTypeSubscriptionDataBuilderProtocol
    ) {
        self.subscriptionsService = subscriptionsService
        self.subscriptionBuilder = subscriptionBuilder
    }
    
    // MARK: - ObjectTypeProviderProtocol
    
    func defaultObjectTypePublisher(spaceId: String) -> AnyPublisher<ObjectType, Never> {
        return $defaultObjectTypes
            .compactMap { [weak self] storage in try? self?.defaultObjectType(storage: storage, spaceId: spaceId) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func defaultObjectType(spaceId: String) throws -> ObjectType {
       return try defaultObjectType(storage: defaultObjectTypes, spaceId: spaceId)
    }
    
    func setDefaultObjectType(type: ObjectType, spaceId: String) {
        defaultObjectTypes[spaceId] = type.id
        AnytypeAnalytics.instance().logDefaultObjectTypeChange(type.analyticsType)
    }

    func objectType(id: String) throws -> ObjectType {
        guard let result = searchTypesById[id] else {
            // TODO: Delete it, because some types can be deleted
            anytypeAssertionFailure("Object type not found by id", info: ["id": id])
            throw ObjectTypeError.objectTypeNotFound
        }
        return result
    }
    
    func objectType(recommendedLayout: DetailsLayout, spaceId: String) throws -> ObjectType {
        let result = objectTypes.filter { $0.recommendedLayout == recommendedLayout && $0.spaceId == spaceId }
        if result.count > 1 {
            anytypeAssertionFailure("Multiple types contains recommendedLayout", info: ["recommendedLayout": "\(recommendedLayout.rawValue)"])
        }
        guard let first = result.first else {
            anytypeAssertionFailure("Object type not found by recommendedLayout", info: ["recommendedLayout": "\(recommendedLayout.rawValue)"])
            throw ObjectTypeError.objectTypeNotFound
        }
        return first
    }
    
    func objectType(uniqueKey: ObjectTypeUniqueKey, spaceId: String) throws -> ObjectType {
        let result = objectTypes.filter { $0.uniqueKey == uniqueKey && $0.spaceId == spaceId }
        if result.count > 1 {
            anytypeAssertionFailure("Multiple types contains uniqueKey", info: ["uniqueKey": "\(uniqueKey)"])
        }
        
        guard let first = result.first else {
            anytypeAssertionFailure("Object type not found by uniqueKey", info: ["uniqueKey": "\(uniqueKey)"])
            throw ObjectTypeError.objectTypeNotFound
        }
        return first
    }
    
    func objectTypes(spaceId: String) -> [ObjectType] {
        return objectTypes.filter { $0.spaceId == spaceId }
    }
    
    func deleteObjectType(id: String) -> ObjectType {
        return ObjectType(
            id: id,
            name: Loc.ObjectType.deletedName,
            iconEmoji: .default,
            description: "",
            hidden: false,
            readonly: true,
            isArchived: false,
            isDeleted: true,
            sourceObject: "",
            spaceId: "",
            uniqueKey: .empty,
            recommendedRelations: [],
            recommendedLayout: nil
        )
    }
    
    func startSubscription() async {
        await subscriptionsService.startSubscriptionAsync(data: subscriptionBuilder.build()) { [weak self] subId, update in
            self?.handleEvent(update: update)
        }
    }
    
    func stopSubscription() {
        subscriptionsService.stopSubscription(id: Self.subscriptionId)
        objectTypes.removeAll()
        updateAllCache()
    }
    
    // MARK: - Private func
    
    private func handleEvent(update: SubscriptionUpdate) {
        objectTypes.applySubscriptionUpdate(update, transform: { ObjectType(details: $0) })
        updateAllCache()
    }
    
    private func updateAllCache() {
        updateSearchCache()
    }
    
    private func updateSearchCache() {
        searchTypesById.removeAll()
        objectTypes.forEach {
            if searchTypesById[$0.id] != nil {
                anytypeAssertionFailure("Dublicate object type found", info: ["id": $0.id])
            }
            searchTypesById[$0.id] = $0
        }
    }
    
    private func findNoteType(spaceId: String) -> ObjectType? {
        let type = objectTypes.first { $0.uniqueKey == .note && $0.spaceId == spaceId }
        if type.isNil {
            anytypeAssertionFailure("Note type not found")
        }
        return type
    }
    
    func defaultObjectType(storage: [String: String], spaceId: String) throws -> ObjectType {
        let typeId = storage[spaceId]
        guard let type = objectTypes.first(where: { $0.id == typeId }) ?? findNoteType(spaceId: spaceId) else {
            anytypeAssertionFailure("Default object type not found")
            throw ObjectTypeError.objectTypeNotFound
        }
        return type
    }
}
