import Combine
import Services
import AnytypeCore

protocol TemplateSelectionInteractorProvider {
    var userTemplates: AnyPublisher<[TemplatePreviewModel], Never> { get }
    var objectTypeId: ObjectTypeId { get }
    
    func setDefaultTemplate(templateId: BlockId) async throws
}

final class DataviewTemplateSelectionInteractorProvider: TemplateSelectionInteractorProvider {
    var userTemplates: AnyPublisher<[TemplatePreviewModel], Never> {
        Publishers.CombineLatest3($templatesDetails, $defaultTemplateId, $typeDefaultTemplateId)
            .map { details, defaultTemplateId, typeDefaultTemplateId in
                let templateId = defaultTemplateId.isNotEmpty ? defaultTemplateId : typeDefaultTemplateId
                return details.map {
                    TemplatePreviewModel(
                        objectDetails: $0,
                        isDefault: $0.id == templateId
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    let objectTypeId: ObjectTypeId
    
    private let setDocument: SetDocumentProtocol
    private let dataView: DataviewView
    
    private let subscriptionService: TemplatesSubscriptionServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let dataviewService: DataviewServiceProtocol
    
    @Published private var templatesDetails = [ObjectDetails]()
    @Published private var defaultTemplateId: BlockId
    @Published private var typeDefaultTemplateId: BlockId
    
    private var cancellables = [AnyCancellable]()
    
    init(
        setDocument: SetDocumentProtocol,
        dataView: DataviewView,
        objectTypeProvider: ObjectTypeProviderProtocol,
        subscriptionService: TemplatesSubscriptionServiceProtocol,
        dataviewService: DataviewServiceProtocol
    ) {
        self.setDocument = setDocument
        self.dataView = dataView
        self.defaultTemplateId = dataView.defaultTemplateID ?? .empty
        self.subscriptionService = subscriptionService
        self.objectTypeProvider = objectTypeProvider
        self.dataviewService = dataviewService
        
        let defaultObjectTypeID = setDocument.activeView.defaultObjectTypeIDWithFallback
        if setDocument.isCollection() || setDocument.isRelationsSet() {
            self.objectTypeId = .dynamic(defaultObjectTypeID)
        } else {
            if let firstSetOf = setDocument.details?.setOf.first {
                self.objectTypeId = .dynamic(firstSetOf)
            } else {
                self.objectTypeId = .dynamic(defaultObjectTypeID)
                anytypeAssertionFailure("Couldn't find default object type in sets", info: ["setId": setDocument.objectId])
            }
        }
        
        self.typeDefaultTemplateId = objectTypeProvider.objectType(id: objectTypeId.rawValue)?.defaultTemplateId ?? .empty
        
        subscribeOnDocmentUpdates()
        loadTemplates()
    }
    
    private func subscribeOnDocmentUpdates() {
        setDocument.activeViewPublisher.sink { [weak self] activeDataView in
            guard let self else { return }
            if self.defaultTemplateId != activeDataView.defaultTemplateID {
                self.defaultTemplateId = activeDataView.defaultTemplateID ?? .empty
            }
        }.store(in: &cancellables)
        
        objectTypeProvider.syncPublisher.sink { [weak self] in
            guard let self else { return }
            let defaultTemplateId = objectTypeProvider.objectType(id: objectTypeId.rawValue)?.defaultTemplateId ?? .empty
            if typeDefaultTemplateId != defaultTemplateId {
                typeDefaultTemplateId = defaultTemplateId
            }
        }.store(in: &cancellables)
    }
    
    private func loadTemplates() {
        subscriptionService.startSubscription(objectType: objectTypeId) { [weak self] _, update in
            self?.templatesDetails.applySubscriptionUpdate(update)
        }
    }
    
    func setDefaultTemplate(templateId: BlockId) async throws {
        let updatedDataView = dataView.updated(defaultTemplateID: templateId)
        try await dataviewService.updateView(updatedDataView)
    }
}
