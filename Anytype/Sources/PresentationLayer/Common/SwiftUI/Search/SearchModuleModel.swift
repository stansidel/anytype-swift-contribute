import Foundation
import Services

struct SearchModuleModel: Identifiable, Hashable {
    let spaceId: String
    let title: String?
    var layoutLimits: [DetailsLayout] = []
    @EquatableNoop var onSelect: (ObjectSearchData) -> Void
    
    var id: Int { hashValue }
}
