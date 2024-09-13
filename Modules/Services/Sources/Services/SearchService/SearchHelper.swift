import ProtobufMessages
import SwiftProtobuf
import Foundation

public class SearchHelper {
    public static func sort(relation: BundledRelationKey, type: DataviewSort.TypeEnum) -> DataviewSort {
        var sort = DataviewSort()
        sort.relationKey = relation.rawValue
        sort.type = type
        
        return sort
    }
    
    public static func customSort(ids: [String]) -> DataviewSort {
        var sort = DataviewSort()
        sort.type = .custom
        sort.customOrder = ids.map { $0.protobufValue }
        
        return sort
    }
    
    public static func isArchivedFilter(isArchived: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = isArchived.protobufValue
        filter.relationKey = BundledRelationKey.isArchived.rawValue
        
        return filter
    }
    
    public static func isFavoriteFilter(isFavorite: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = isFavorite.protobufValue
        filter.relationKey = BundledRelationKey.isFavorite.rawValue
        
        return filter
    }
    
    public static func isDeletedFilter(isDeleted: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = isDeleted.protobufValue
        filter.relationKey = BundledRelationKey.isDeleted.rawValue
        
        return filter
    }
    
    public static func isHidden(_ isHidden: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = isHidden.protobufValue
        filter.relationKey = BundledRelationKey.isHidden.rawValue
        
        return filter
    }
    
    public static func lastOpenedDateNotNilFilter() -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notEmpty
        filter.value = nil
        filter.relationKey = BundledRelationKey.lastOpenedDate.rawValue
        
        return filter
    }
    
    public static func lastModifiedDateFrom(_ date: Date) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .greaterOrEqual
        filter.value = date.timeIntervalSince1970.protobufValue
        filter.relationKey = BundledRelationKey.lastModifiedDate.rawValue
        
        return filter
    }
    
    public static func typeFilter(typeIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = typeIds.protobufValue
        filter.relationKey = BundledRelationKey.type.rawValue
        
        return filter
    }
    
    public static func excludedTypeFilter(_ typeIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = typeIds.protobufValue
        filter.relationKey = BundledRelationKey.type.rawValue
        
        return filter
    }
    
    public static func layoutFilter(_ layouts: [DetailsLayout]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = layouts.map(\.rawValue).protobufValue
        filter.relationKey = BundledRelationKey.layout.rawValue
        
        return filter
    }
    
    public static func participantStatusFilter(_ status: ParticipantStatus...) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = status.map(\.rawValue).protobufValue
        filter.relationKey = BundledRelationKey.participantStatus.rawValue
        
        return filter
    }
    
    public static func excludedLayoutFilter(_ layouts: [DetailsLayout]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = layouts.map(\.rawValue).protobufValue
        filter.relationKey = BundledRelationKey.layout.rawValue
        
        return filter
    }
    
    public static func recomendedLayoutFilter(_ layouts: [DetailsLayout]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = layouts.map(\.rawValue).protobufValue
        filter.relationKey = BundledRelationKey.recommendedLayout.rawValue
        
        return filter
    }
    
    public static func includeIdsFilter(_ typeIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = typeIds.protobufValue
        filter.relationKey = BundledRelationKey.id.rawValue
        
        return filter
    }
    
    public static func sharedObjectsFilters() -> [DataviewFilter] {
        var spaceFilter = DataviewFilter()
        spaceFilter.condition = .notEmpty
        spaceFilter.value = nil
        spaceFilter.relationKey = BundledRelationKey.spaceId.rawValue
   
        var highlightedFilter = DataviewFilter()
        highlightedFilter.condition = .equal
        highlightedFilter.value = true
        highlightedFilter.relationKey = BundledRelationKey.isHighlighted.rawValue
        
        return [
            spaceFilter,
            highlightedFilter
        ]
    }
    
    public static func excludedIdsFilter(_ ids: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = ids.protobufValue
        
        filter.relationKey = BundledRelationKey.id.rawValue
        
        return filter
    }
    
    public static func relationKey(_ relationKey: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = relationKey.protobufValue
        
        filter.relationKey = BundledRelationKey.relationKey.rawValue
        
        return filter
    }
    
    public static func excludedRelationKeys(_ relationKeys: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = relationKeys.protobufValue
        
        filter.relationKey = BundledRelationKey.relationKey.rawValue
        
        return filter
    }

    public static func templatesFilters(type: String, spaceId spaceIdValue: String) -> [DataviewFilter] {
        [
            isArchivedFilter(isArchived: false),
            isDeletedFilter(isDeleted: false),
            templateScheme(include: true),
            templateTypeFilter(type: type),
            spaceId(spaceIdValue)
        ]
    }
    
    public static func spaceId(_ spaceId: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = spaceId.protobufValue
        
        filter.relationKey = BundledRelationKey.spaceId.rawValue
        
        return filter
    }
    
    public static func objectsIds(_ objectsIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = objectsIds.protobufValue
        
        filter.relationKey = BundledRelationKey.id.rawValue
        
        return filter
    }
    
    public static func identityProfileLink(_ identityId: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = identityId.protobufValue
        
        filter.relationKey = BundledRelationKey.identityProfileLink.rawValue
        
        return filter
    }
    
    public static func spaceIds(_ spaceIds: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = spaceIds.protobufValue
        
        filter.relationKey = BundledRelationKey.spaceId.rawValue
        
        return filter
    }
    
    public static func fileSyncStatus(_ status: FileSyncStatus) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = status.rawValue.protobufValue
        filter.relationKey = BundledRelationKey.fileSyncStatus.rawValue
        
        return filter
    }
    
    public static func excludeObjectRestriction(_ restriction: ObjectRestriction) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = restriction.rawValue.protobufValue
        filter.relationKey = BundledRelationKey.restrictions.rawValue
        
        return filter
    }
    
    public static func relationReadonlyValue(_ value: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = value.protobufValue
        filter.relationKey = BundledRelationKey.relationReadonlyValue.rawValue
        
        return filter
    }
    
    public static func spaceAccountStatusExcludeFilter(_ statuses: SpaceStatus...) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .notIn
        filter.value = statuses.map { $0.rawValue }.protobufValue
        filter.relationKey = BundledRelationKey.spaceAccountStatus.rawValue
        
        return filter
    }
    
    public static func spaceLocalStatusFilter(_ status: SpaceStatus) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = status.rawValue.protobufValue
        filter.relationKey = BundledRelationKey.spaceLocalStatus.rawValue
        
        return filter
    }
    
    public static func templateScheme(include: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = include ? .equal : .notEqual
        filter.relationKey = "\(BundledRelationKey.type.rawValue).\(BundledRelationKey.uniqueKey.rawValue)"
        filter.value = ObjectTypeUniqueKey.template.value.protobufValue

        return filter
    }
    
    public static func isHiddenDiscovery(_ isHidden: Bool) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = isHidden.protobufValue
        
        filter.relationKey = BundledRelationKey.isHiddenDiscovery.rawValue
        
        return filter
    }
    
    public static func notHiddenFilters(isArchive: Bool = false, includeHiddenDiscovery: Bool = true) -> [DataviewFilter] {
        .builder {
            SearchHelper.isHidden(false)
            if includeHiddenDiscovery {
                SearchHelper.isHiddenDiscovery(false)
            }
            SearchHelper.isDeletedFilter(isDeleted: false)
            SearchHelper.isArchivedFilter(isArchived: isArchive)
        }
    }
    
    public static func onlyUnlinked() -> [DataviewFilter] {
        .builder {
            SearchHelper.emptyLinks()
            SearchHelper.emptyBacklinks()
        }
    }
    
    // MARK: - Private

    private static func templateTypeFilter(type: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .equal
        filter.value = type.protobufValue
        filter.relationKey = BundledRelationKey.targetObjectType.rawValue

        return filter
    }
    
    private static func emptyLinks() -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .empty
        filter.relationKey = BundledRelationKey.links.rawValue
        
        return filter
    }
    
    private static func emptyBacklinks() -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .empty
        filter.relationKey = BundledRelationKey.backlinks.rawValue
        
        return filter
    }
}
