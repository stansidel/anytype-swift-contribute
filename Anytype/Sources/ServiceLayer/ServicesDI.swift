import Foundation
import SecureService
import Services
import SharedContentManager
import DeepLinks
import AnytypeCore
@_exported import Factory

extension Container {
    
    var activeWorkspaceStorage: Factory<any ActiveWorkpaceStorageProtocol> {
        self { ActiveWorkspaceStorage() }.singleton
    }
    
    var accountManager: Factory<any AccountManagerProtocol> {
        self { AccountManager() }.singleton
    }
    
    var accountEventHandler: Factory<any AccountEventHandlerProtocol> {
        self { AccountEventHandler() }.singleton
    }
    
    var workspaceStorage: Factory<any WorkspacesStorageProtocol> {
        self { WorkspacesStorage() }.singleton
    }
    
    var singleObjectSubscriptionService: Factory<any SingleObjectSubscriptionServiceProtocol> {
        self { SingleObjectSubscriptionService() }
    }
    
    var loginStateService: Factory<any LoginStateServiceProtocol> {
        self { LoginStateService() }.singleton
    }
    
    var subscriptionToggler: Factory<any SubscriptionTogglerProtocol> {
        self { SubscriptionToggler() }.shared
    }
    
    var pasteboardHelper: Factory<any PasteboardHelperProtocol> {
        self { PasteboardHelper() }
    }
    
    var pasteboardBlockService: Factory<any PasteboardBlockServiceProtocol> {
        self { PasteboardBlockService() }
    }
    
    var localRepoService: Factory<any LocalRepoServiceProtocol> {
        self { LocalRepoService() }.shared
    }
    
    var keychainStore: Factory<any KeychainStoreProtocol> {
        self { KeychainStore() }.shared
    }
    
    var seedService: Factory<any SeedServiceProtocol> {
        self { SeedService() }.shared
    }
    
    var usecaseService: Factory<any UsecaseServiceProtocol> {
        self { UsecaseService() }.shared
    }
    
    var fileActionsService: Factory<any FileActionsServiceProtocol> {
        self { FileActionsService() }.shared
    }
    
    var searchService: Factory<any SearchServiceProtocol> {
        self { SearchService() }.shared
    }
    
    var searchWithMetaService: Factory<any SearchWithMetaServiceProtocol> {
        self { SearchWithMetaService() }.shared
    }
    
    var subscriptionStorageProvider: Factory<any SubscriptionStorageProviderProtocol> {
        self { SubscriptionStorageProvider() }.singleton
    }
    
    var systemURLService: Factory<any SystemURLServiceProtocol> {
        self { SystemURLService() }.shared
    }
    
    var groupsSubscriptionsHandler: Factory<any GroupsSubscriptionsHandlerProtocol> {
        self { GroupsSubscriptionsHandler() }
    }
    
    var objectTypeProvider: Factory<any ObjectTypeProviderProtocol> {
        self { ObjectTypeProvider.shared }
    }
    
    var favoriteSubscriptionService: Factory<any FavoriteSubscriptionServiceProtocol> {
        self { FavoriteSubscriptionService() }
    }
    
    var recentSubscriptionService: Factory<any RecentSubscriptionServiceProtocol> {
        self { RecentSubscriptionService() }
    }
    
    var setsSubscriptionService: Factory<any SetsSubscriptionServiceProtocol> {
        self { SetsSubscriptionService() }
    }
    
    var collectionsSubscriptionService: Factory<any CollectionsSubscriptionServiceProtocol> {
        self { CollectionsSubscriptionService() }
    }
    
    var binSubscriptionService: Factory<any BinSubscriptionServiceProtocol> {
        self { BinSubscriptionService() }
    }
    
    var treeSubscriptionDataBuilder: Factory<any TreeSubscriptionDataBuilderProtocol> {
        self { TreeSubscriptionDataBuilder() }
    }
    
    var treeSubscriptionManager: Factory<any TreeSubscriptionManagerProtocol> {
        self { TreeSubscriptionManager() }
    }
    
    var filesSubscriptionManager: Factory<any FilesSubscriptionServiceProtocol> {
        self { FilesSubscriptionService() }
    }
    
    var templatesSubscription: Factory<any TemplatesSubscriptionServiceProtocol> {
        self { TemplatesSubscriptionService() }
    }
    
    var defaultObjectCreationService: Factory<any DefaultObjectCreationServiceProtocol> {
        self { DefaultObjectCreationService() }.shared
    }
    
    var appErrorLoggerConfiguration: Factory<any AppErrorLoggerConfigurationProtocol> {
        self { AppErrorLoggerConfiguration() }.shared
    }
    
    var localAuthService: Factory<any LocalAuthServiceProtocol> {
        self { LocalAuthService() }.shared
    }
    
    var cameraPermissionVerifier: Factory<any CameraPermissionVerifierProtocol> {
        self { CameraPermissionVerifier() }.shared
    }
    
    var fileErrorEventHandler: Factory<any FileErrorEventHandlerProtocol> {
        self { FileErrorEventHandler() }.singleton
    }
    
    var sceneStateNotifier: Factory<any SceneStateNotifierProtocol> {
        self { SceneStateNotifier() }.singleton
    }
    
    var deviceSceneStateListener: Factory<any DeviceSceneStateListenerProtocol> {
        self { DeviceSceneStateListener() }.singleton
    }
    
    var textServiceHandler: Factory<any TextServiceProtocol> {
        self { TextServiceHandler() }.shared
    }
    
    var relationDetailsStorage: Factory<any RelationDetailsStorageProtocol> {
        self { RelationDetailsStorage() }.singleton
    }
    
    var relationSubscriptionDataBuilder: Factory<any RelationSubscriptionDataBuilderProtocol> {
        self { RelationSubscriptionDataBuilder() }
    }
    
    var middlewareConfigurationProvider: Factory<any MiddlewareConfigurationProviderProtocol> {
        self { MiddlewareConfigurationProvider() }.singleton
    }
    
    var documentsProvider: Factory<any DocumentsProviderProtocol> {
        self { DocumentsProvider() }.singleton
    }
    
    var blockWidgetExpandedService: Factory<any BlockWidgetExpandedServiceProtocol> {
        self { BlockWidgetExpandedService() }.shared
    }
    
    var applicationStateService: Factory<any ApplicationStateServiceProtocol> {
        self { ApplicationStateService() }.singleton
    }
    
    var documentService: Factory<any OpenedDocumentsProviderProtocol> {
        self { OpenedDocumentsProvider() }.singleton
    }
    
    var typesPinsStorage: Factory<any TypesPinStorageProtocol> {
        self { TypesPinStorage() }.shared
    }
    
    var objectsCommonSubscriptionDataBuilder: Factory<any ObjectsCommonSubscriptionDataBuilderProtocol> {
        self { ObjectsCommonSubscriptionDataBuilder() }.shared
    }
    
    var sharedContentManager: Factory<any SharedContentManagerProtocol> {
        self { SharingDI.shared.sharedContentManager() }
    }
    
    var typesService: Factory<any TypesServiceProtocol> {
        self { TypesService() }.shared
    }
    
    var fileLimitsStorage: Factory<any FileLimitsStorageProtocol> {
        self { FileLimitsStorage() }.shared
    }
    
    var workspacesSubscriptionBuilder: Factory<any WorkspacesSubscriptionBuilderProtocol> {
        self { WorkspacesSubscriptionBuilder() }.shared
    }
    
    var serverConfigurationStorage: Factory<any ServerConfigurationStorageProtocol> {
        self { ServerConfigurationStorage() }.singleton
    }
    
    var authService: Factory<any AuthServiceProtocol> {
        self { AuthService() }.shared
    }
    
    var appActionStorage: Factory<AppActionStorage> {
        self { AppActionStorage() }.singleton
    }
    
    var quickActionShortcutBuilder: Factory<any QuickActionShortcutBuilderProtocol> {
        self { QuickActionShortcutBuilder() }.shared
    }
    
    var deepLinkParser: Factory<any DeepLinkParserProtocol> {
        self { DeepLinkDI.shared.parser(isDebug: CoreEnvironment.isDebug) }
    }
    
    var universalLinkParser: Factory<any UniversalLinkParserProtocol> {
        self { UniversalLinkParser() }.shared
    }
    
    var detailsService: Factory<any DetailsServiceProtocol> {
        self { DetailsService() }.shared
    }
    
    var pasteboardBlockDocumentService: Factory<any PasteboardBlockDocumentServiceProtocol> {
        self { PasteboardBlockDocumentService() }.shared
    }
    
    var audioSessionService: Factory<any AudioSessionServiceProtocol> {
        self { AudioSessionService() }.singleton
    }
    
    var textRelationEditingService: Factory<any TextRelationEditingServiceProtocol> {
        self { TextRelationEditingService() }.shared
    }
    
    var accountParticipantsStorage: Factory<any AccountParticipantsStorageProtocol> {
        self { AccountParticipantsStorage() }.singleton
    }

    var participantSpacesStorage: Factory<any ParticipantSpacesStorageProtocol> {
        self { ParticipantSpacesStorage() }.singleton
    }
    
    var membershipStatusStorage: Factory<any MembershipStatusStorageProtocol> {
        self { MembershipStatusStorage() }.singleton
    }
    
    var membershipMetadataProvider: Factory<any MembershipMetadataProviderProtocol> {
        self { MembershipMetadataProvider() }.shared
    }
    
    var objectHeaderUploadingService: Factory<any ObjectHeaderUploadingServiceProtocol> {
        self { ObjectHeaderUploadingService() }.shared
    }
    
    var storeKitService: Factory<any StoreKitServiceProtocol> {
        self { StoreKitService() }.singleton
    }
    
    var mentionObjectsService: Factory<any MentionObjectsServiceProtocol> {
        self { MentionObjectsService() }.shared
    }
    
    var appVersionService: Factory<any AppVersionServiceProtocol> {
        self { AppVersionService() }.singleton
    }
    
    var middlewareEventsListener: Factory<any MiddlewareEventsListenerProtocol> {
        self { MiddlewareEventsListener() }.singleton
    }
    
    var syncStatusStorage: Factory< any SyncStatusStorageProtocol> {
        self { SyncStatusStorage() }.singleton
    }
    
    var p2pStatusStorage: Factory< any P2PStatusStorageProtocol> {
        self { P2PStatusStorage() }.singleton
    }
    
    var participantSubscriptionProvider: Factory<any ParticipantsSubscriptionProviderProtocol> {
        self { ParticipantsSubscriptionProvider() }.singleton
    }
}
