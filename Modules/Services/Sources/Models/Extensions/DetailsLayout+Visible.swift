import AnytypeCore

public extension DetailsLayout {
    // TODO: Rollback
    static var visibleLayouts: [DetailsLayout] = [.basic, .bookmark, .collection, .note, .profile, .set, .todo, .file, .image]
    static var supportedForEditLayouts: [DetailsLayout] = [.basic, .bookmark, .collection, .file, .image, .note, .profile, .set, .todo]
    static var supportedForCreationInSets: [DetailsLayout] = pageLayouts
}


// For editor
public extension DetailsLayout {
    static var editorLayouts: [DetailsLayout] = [
        .note,
        .basic,
        .profile,
        .todo
    ]
    
    static var pageLayouts: [DetailsLayout] = editorLayouts + [.bookmark]
    
    static var fileLayouts: [DetailsLayout] = [
        .file,
        .image,
        .audio,
        .video
    ]
    
    static var systemLayouts: [DetailsLayout] = [
        .objectType,
        .relation,
        .relationOption,
        .relationOptionList,
        .dashboard,
        .database,
        .space
    ]
    
    static var fileAndSystemLayouts: [DetailsLayout] = fileLayouts + systemLayouts
    static var layoutsWithoutTemplate: [DetailsLayout] = [
        .set,
        .collection,
        .bookmark
    ] + fileAndSystemLayouts
    
    
    var isTemplatesAvailable: Bool {
        !DetailsLayout.layoutsWithoutTemplate.contains(self) &&
        DetailsLayout.pageLayouts.contains(self)
    }
}
