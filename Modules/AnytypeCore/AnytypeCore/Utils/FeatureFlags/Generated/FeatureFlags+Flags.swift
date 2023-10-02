// Generated using Sourcery 1.9.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length

public extension FeatureFlags {

    // Static value reader
    static var setTemplateSelection: Bool {
        value(for: .setTemplateSelection)
    }

    static var setKanbanView: Bool {
        value(for: .setKanbanView)
    }

    static var fullInlineSetImpl: Bool {
        value(for: .fullInlineSetImpl)
    }

    static var dndOnCollectionsAndSets: Bool {
        value(for: .dndOnCollectionsAndSets)
    }

    static var multiSpace: Bool {
        value(for: .multiSpace)
    }

    static var multiSpaceSettings: Bool {
        value(for: .multiSpaceSettings)
    }

    static var newCodeLanguages: Bool {
        value(for: .newCodeLanguages)
    }

    static var newSetSettings: Bool {
        value(for: .newSetSettings)
    }

    static var ipadIncreaseWidth: Bool {
        value(for: .ipadIncreaseWidth)
    }

    static var rainbowViews: Bool {
        value(for: .rainbowViews)
    }

    static var showAlertOnAssert: Bool {
        value(for: .showAlertOnAssert)
    }

    static var analytics: Bool {
        value(for: .analytics)
    }

    static var analyticsAlerts: Bool {
        value(for: .analyticsAlerts)
    }

    static var nonfatalAlerts: Bool {
        value(for: .nonfatalAlerts)
    }

    // All toggles
    static let features: [FeatureDescription] = [
        .setTemplateSelection,
        .setKanbanView,
        .fullInlineSetImpl,
        .dndOnCollectionsAndSets,
        .multiSpace,
        .multiSpaceSettings,
        .newCodeLanguages,
        .newSetSettings,
        .ipadIncreaseWidth,
        .rainbowViews,
        .showAlertOnAssert,
        .analytics,
        .analyticsAlerts,
        .nonfatalAlerts
    ]
}
