import Services
import SwiftUI

@MainActor
final class VersionHistoryViewModel: ObservableObject {
    
    @Published var groups = [VersionHistoryDataGroup]()
    
    private let objectId: String
    private var rawVersions = [VersionHistory]()
    private var participantsDict = [String: Participant]()
    
    @Injected(\.historyVersionsService)
    private var historyVersionsService: any HistoryVersionsServiceProtocol
    @Injected(\.activeSpaceParticipantStorage)
    private var activeSpaceParticipantStorage: any ActiveSpaceParticipantStorageProtocol
    @Injected(\.versionHistoryDataBuilder)
    private var versionHistoryDataBuilder: any VersionHistoryDataBuilderProtocol
    
    init(objectId: String) {
        self.objectId = objectId
    }
    
    func startParticipantsSubscription() async {
        for await participants in activeSpaceParticipantStorage.participantsPublisher.values {
            participantsDict = [:]
            participants.forEach { participant in
                participantsDict[participant.id] = participant
            }
            updateView()
        }
    }
    
    func getVersions() async {
        do {
            rawVersions = try await historyVersionsService.getVersions(objectId: objectId)
            updateView()
        } catch {
            groups = []
        }
    }
    
    func updateView() {
        guard rawVersions.isNotEmpty, !participantsDict.keys.isEmpty else { return }
        groups = versionHistoryDataBuilder.buildData(for: rawVersions, participants: participantsDict)
    }
}
