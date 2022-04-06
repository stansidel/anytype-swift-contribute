// DO NOT EDIT
//
// Generated automatically by the AnytypeSwiftCodegen.
//
// For more info see:
// https://github.com/anytypeio/anytype-swift-codegen

import Foundation
import Lib
import SwiftProtobuf

/// Begin of classes

/// Adapts interface of private framework.
public protocol ServiceEventsHandlerProtocol: AnyObject {
  func handle(_ data: Data?)
}

/// Provides the following functionality
/// - Receive events from `Lib` and transfer them to a wrapped value.
///
/// In a nutshell, it do the following.
///
/// - It consumes ( with a weak ownership ) a value which adopts public interface.
/// - Subscribes as event handler to library events stream.
/// - Transfer events from library to a value.
///
public class ServiceMessageHandlerAdapter: NSObject {
  public typealias Adapter = ServiceEventsHandlerProtocol
  private(set) weak var value: Adapter?
  public init(value: Adapter) {
    self.value = value
    super.init()
    self.listen()
  }
  public override init() {
    super.init()
  }
  public func with(value: Adapter?) -> Self {
    self.value = value
    if value != nil {
      self.listen()
    }
    return self
  }
  /// Don't forget to call it.
  public func listen() {
    Lib.ServiceSetEventHandlerMobile(self)
  }
}

/// Private `ServiceMessageHandlerProtocol` adoption.
extension ServiceMessageHandlerAdapter: ServiceMessageHandlerProtocol {
  public func handle(_ b: Data?) {
    self.value?.handle(b)
  }
}

/// End of classes

extension Anytype_Event {
  public init(messages: [Anytype_Event.Message], contextID: String, initiator: Anytype_Model_Account, traceID: String) {
    self.messages = messages
    self.contextID = contextID
    self.initiator = initiator
    self.traceID = traceID
  }
}

extension Anytype_Event.Account.Config.Update {
  public init(config: Anytype_Model_Account.Config, status: Anytype_Model_Account.Status) {
    self.config = config
    self.status = status
  }
}

extension Anytype_Event.Account.Details {
  public init(profileID: String, details: SwiftProtobuf.Google_Protobuf_Struct) {
    self.profileID = profileID
    self.details = details
  }
}

extension Anytype_Event.Account.Show {
  public init(index: Int32, account: Anytype_Model_Account) {
    self.index = index
    self.account = account
  }
}

extension Anytype_Event.Account.Update {
  public init(config: Anytype_Model_Account.Config, status: Anytype_Model_Account.Status) {
    self.config = config
    self.status = status
  }
}

extension Anytype_Event.Block.Add {
  public init(blocks: [Anytype_Model_Block]) {
    self.blocks = blocks
  }
}

extension Anytype_Event.Block.Dataview.RecordsDelete {
  public init(id: String, viewID: String, removed: [String]) {
    self.id = id
    self.viewID = viewID
    self.removed = removed
  }
}

extension Anytype_Event.Block.Dataview.RecordsInsert {
  public init(id: String, viewID: String, records: [SwiftProtobuf.Google_Protobuf_Struct], insertPosition: UInt32) {
    self.id = id
    self.viewID = viewID
    self.records = records
    self.insertPosition = insertPosition
  }
}

extension Anytype_Event.Block.Dataview.RecordsSet {
  public init(id: String, viewID: String, records: [SwiftProtobuf.Google_Protobuf_Struct], total: UInt32) {
    self.id = id
    self.viewID = viewID
    self.records = records
    self.total = total
  }
}

extension Anytype_Event.Block.Dataview.RecordsUpdate {
  public init(id: String, viewID: String, records: [SwiftProtobuf.Google_Protobuf_Struct]) {
    self.id = id
    self.viewID = viewID
    self.records = records
  }
}

extension Anytype_Event.Block.Dataview.RelationDelete {
  public init(id: String, relationKey: String) {
    self.id = id
    self.relationKey = relationKey
  }
}

extension Anytype_Event.Block.Dataview.RelationSet {
  public init(id: String, relationKey: String, relation: Anytype_Model_Relation) {
    self.id = id
    self.relationKey = relationKey
    self.relation = relation
  }
}

extension Anytype_Event.Block.Dataview.SourceSet {
  public init(id: String, source: [String]) {
    self.id = id
    self.source = source
  }
}

extension Anytype_Event.Block.Dataview.ViewDelete {
  public init(id: String, viewID: String) {
    self.id = id
    self.viewID = viewID
  }
}

extension Anytype_Event.Block.Dataview.ViewOrder {
  public init(id: String, viewIds: [String]) {
    self.id = id
    self.viewIds = viewIds
  }
}

extension Anytype_Event.Block.Dataview.ViewSet {
  public init(id: String, viewID: String, view: Anytype_Model_Block.Content.Dataview.View, offset: UInt32, limit: UInt32) {
    self.id = id
    self.viewID = viewID
    self.view = view
    self.offset = offset
    self.limit = limit
  }
}

extension Anytype_Event.Block.Delete {
  public init(blockIds: [String]) {
    self.blockIds = blockIds
  }
}

extension Anytype_Event.Block.FilesUpload {
  public init(blockID: String, filePath: [String]) {
    self.blockID = blockID
    self.filePath = filePath
  }
}

extension Anytype_Event.Block.Fill.Align {
  public init(id: String, align: Anytype_Model_Block.Align) {
    self.id = id
    self.align = align
  }
}

extension Anytype_Event.Block.Fill.BackgroundColor {
  public init(id: String, backgroundColor: String) {
    self.id = id
    self.backgroundColor = backgroundColor
  }
}

extension Anytype_Event.Block.Fill.Bookmark {
  public init(
    id: String, url: Anytype_Event.Block.Fill.Bookmark.Url, title: Anytype_Event.Block.Fill.Bookmark.Title, description_p: Anytype_Event.Block.Fill.Bookmark.Description,
    imageHash: Anytype_Event.Block.Fill.Bookmark.ImageHash, faviconHash: Anytype_Event.Block.Fill.Bookmark.FaviconHash, type: Anytype_Event.Block.Fill.Bookmark.TypeMessage
  ) {
    self.id = id
    self.url = url
    self.title = title
    self.description_p = description_p
    self.imageHash = imageHash
    self.faviconHash = faviconHash
    self.type = type
  }
}

extension Anytype_Event.Block.Fill.Bookmark.Description {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.Bookmark.FaviconHash {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.Bookmark.ImageHash {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.Bookmark.Title {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.Bookmark.TypeMessage {
  public init(value: Anytype_Model_LinkPreview.TypeEnum) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.Bookmark.Url {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.ChildrenIds {
  public init(id: String, childrenIds: [String]) {
    self.id = id
    self.childrenIds = childrenIds
  }
}

extension Anytype_Event.Block.Fill.DatabaseRecords {
  public init(id: String, records: [SwiftProtobuf.Google_Protobuf_Struct]) {
    self.id = id
    self.records = records
  }
}

extension Anytype_Event.Block.Fill.Details {
  public init(id: String, details: SwiftProtobuf.Google_Protobuf_Struct) {
    self.id = id
    self.details = details
  }
}

extension Anytype_Event.Block.Fill.Div {
  public init(id: String, style: Anytype_Event.Block.Fill.Div.Style) {
    self.id = id
    self.style = style
  }
}

extension Anytype_Event.Block.Fill.Div.Style {
  public init(value: Anytype_Model_Block.Content.Div.Style) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.Fields {
  public init(id: String, fields: SwiftProtobuf.Google_Protobuf_Struct) {
    self.id = id
    self.fields = fields
  }
}

extension Anytype_Event.Block.Fill.File {
  public init(
    id: String, type: Anytype_Event.Block.Fill.File.TypeMessage, state: Anytype_Event.Block.Fill.File.State, mime: Anytype_Event.Block.Fill.File.Mime, hash: Anytype_Event.Block.Fill.File.Hash,
    name: Anytype_Event.Block.Fill.File.Name, size: Anytype_Event.Block.Fill.File.Size, style: Anytype_Event.Block.Fill.File.Style
  ) {
    self.id = id
    self.type = type
    self.state = state
    self.mime = mime
    self.hash = hash
    self.name = name
    self.size = size
    self.style = style
  }
}

extension Anytype_Event.Block.Fill.File.Hash {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.File.Mime {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.File.Name {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.File.Size {
  public init(value: Int64) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.File.State {
  public init(value: Anytype_Model_Block.Content.File.State) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.File.Style {
  public init(value: Anytype_Model_Block.Content.File.Style) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.File.TypeMessage {
  public init(value: Anytype_Model_Block.Content.File.TypeEnum) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.File.Width {
  public init(value: Int32) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.Link {
  public init(id: String, targetBlockID: Anytype_Event.Block.Fill.Link.TargetBlockId, style: Anytype_Event.Block.Fill.Link.Style, fields: Anytype_Event.Block.Fill.Link.Fields) {
    self.id = id
    self.targetBlockID = targetBlockID
    self.style = style
    self.fields = fields
  }
}

extension Anytype_Event.Block.Fill.Link.Fields {
  public init(value: SwiftProtobuf.Google_Protobuf_Struct) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.Link.Style {
  public init(value: Anytype_Model_Block.Content.Link.Style) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.Link.TargetBlockId {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.Restrictions {
  public init(id: String, restrictions: Anytype_Model_Block.Restrictions) {
    self.id = id
    self.restrictions = restrictions
  }
}

extension Anytype_Event.Block.Fill.Text {
  public init(
    id: String, text: Anytype_Event.Block.Fill.Text.Text, style: Anytype_Event.Block.Fill.Text.Style, marks: Anytype_Event.Block.Fill.Text.Marks, checked: Anytype_Event.Block.Fill.Text.Checked,
    color: Anytype_Event.Block.Fill.Text.Color
  ) {
    self.id = id
    self.text = text
    self.style = style
    self.marks = marks
    self.checked = checked
    self.color = color
  }
}

extension Anytype_Event.Block.Fill.Text.Checked {
  public init(value: Bool) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.Text.Color {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.Text.Marks {
  public init(value: Anytype_Model_Block.Content.Text.Marks) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.Text.Style {
  public init(value: Anytype_Model_Block.Content.Text.Style) {
    self.value = value
  }
}

extension Anytype_Event.Block.Fill.Text.Text {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.MarksInfo {
  public init(marksInRange: [Anytype_Model_Block.Content.Text.Mark.TypeEnum]) {
    self.marksInRange = marksInRange
  }
}

extension Anytype_Event.Block.Set.Align {
  public init(id: String, align: Anytype_Model_Block.Align) {
    self.id = id
    self.align = align
  }
}

extension Anytype_Event.Block.Set.BackgroundColor {
  public init(id: String, backgroundColor: String) {
    self.id = id
    self.backgroundColor = backgroundColor
  }
}

extension Anytype_Event.Block.Set.Bookmark {
  public init(
    id: String, url: Anytype_Event.Block.Set.Bookmark.Url, title: Anytype_Event.Block.Set.Bookmark.Title, description_p: Anytype_Event.Block.Set.Bookmark.Description,
    imageHash: Anytype_Event.Block.Set.Bookmark.ImageHash, faviconHash: Anytype_Event.Block.Set.Bookmark.FaviconHash, type: Anytype_Event.Block.Set.Bookmark.TypeMessage
  ) {
    self.id = id
    self.url = url
    self.title = title
    self.description_p = description_p
    self.imageHash = imageHash
    self.faviconHash = faviconHash
    self.type = type
  }
}

extension Anytype_Event.Block.Set.Bookmark.Description {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Bookmark.FaviconHash {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Bookmark.ImageHash {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Bookmark.Title {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Bookmark.TypeMessage {
  public init(value: Anytype_Model_LinkPreview.TypeEnum) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Bookmark.Url {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.ChildrenIds {
  public init(id: String, childrenIds: [String]) {
    self.id = id
    self.childrenIds = childrenIds
  }
}

extension Anytype_Event.Block.Set.Div {
  public init(id: String, style: Anytype_Event.Block.Set.Div.Style) {
    self.id = id
    self.style = style
  }
}

extension Anytype_Event.Block.Set.Div.Style {
  public init(value: Anytype_Model_Block.Content.Div.Style) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Fields {
  public init(id: String, fields: SwiftProtobuf.Google_Protobuf_Struct) {
    self.id = id
    self.fields = fields
  }
}

extension Anytype_Event.Block.Set.File {
  public init(
    id: String, type: Anytype_Event.Block.Set.File.TypeMessage, state: Anytype_Event.Block.Set.File.State, mime: Anytype_Event.Block.Set.File.Mime, hash: Anytype_Event.Block.Set.File.Hash,
    name: Anytype_Event.Block.Set.File.Name, size: Anytype_Event.Block.Set.File.Size, style: Anytype_Event.Block.Set.File.Style
  ) {
    self.id = id
    self.type = type
    self.state = state
    self.mime = mime
    self.hash = hash
    self.name = name
    self.size = size
    self.style = style
  }
}

extension Anytype_Event.Block.Set.File.Hash {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.File.Mime {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.File.Name {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.File.Size {
  public init(value: Int64) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.File.State {
  public init(value: Anytype_Model_Block.Content.File.State) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.File.Style {
  public init(value: Anytype_Model_Block.Content.File.Style) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.File.TypeMessage {
  public init(value: Anytype_Model_Block.Content.File.TypeEnum) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.File.Width {
  public init(value: Int32) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Latex {
  public init(id: String, text: Anytype_Event.Block.Set.Latex.Text) {
    self.id = id
    self.text = text
  }
}

extension Anytype_Event.Block.Set.Latex.Text {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Link {
  public init(id: String, targetBlockID: Anytype_Event.Block.Set.Link.TargetBlockId, style: Anytype_Event.Block.Set.Link.Style, fields: Anytype_Event.Block.Set.Link.Fields) {
    self.id = id
    self.targetBlockID = targetBlockID
    self.style = style
    self.fields = fields
  }
}

extension Anytype_Event.Block.Set.Link.Fields {
  public init(value: SwiftProtobuf.Google_Protobuf_Struct) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Link.Style {
  public init(value: Anytype_Model_Block.Content.Link.Style) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Link.TargetBlockId {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Relation {
  public init(id: String, key: Anytype_Event.Block.Set.Relation.Key) {
    self.id = id
    self.key = key
  }
}

extension Anytype_Event.Block.Set.Relation.Key {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Restrictions {
  public init(id: String, restrictions: Anytype_Model_Block.Restrictions) {
    self.id = id
    self.restrictions = restrictions
  }
}

extension Anytype_Event.Block.Set.Text {
  public init(
    id: String, text: Anytype_Event.Block.Set.Text.Text, style: Anytype_Event.Block.Set.Text.Style, marks: Anytype_Event.Block.Set.Text.Marks, checked: Anytype_Event.Block.Set.Text.Checked,
    color: Anytype_Event.Block.Set.Text.Color, iconEmoji: Anytype_Event.Block.Set.Text.IconEmoji, iconImage: Anytype_Event.Block.Set.Text.IconImage
  ) {
    self.id = id
    self.text = text
    self.style = style
    self.marks = marks
    self.checked = checked
    self.color = color
    self.iconEmoji = iconEmoji
    self.iconImage = iconImage
  }
}

extension Anytype_Event.Block.Set.Text.Checked {
  public init(value: Bool) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Text.Color {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Text.IconEmoji {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Text.IconImage {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Text.Marks {
  public init(value: Anytype_Model_Block.Content.Text.Marks) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Text.Style {
  public init(value: Anytype_Model_Block.Content.Text.Style) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Text.Text {
  public init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Message {
  public init(value: Anytype_Event.Message.OneOf_Value?) {
    self.value = value
  }
}

extension Anytype_Event.Object.Details.Amend {
  public init(id: String, details: [Anytype_Event.Object.Details.Amend.KeyValue], subIds: [String]) {
    self.id = id
    self.details = details
    self.subIds = subIds
  }
}

extension Anytype_Event.Object.Details.Amend.KeyValue {
  public init(key: String, value: SwiftProtobuf.Google_Protobuf_Value) {
    self.key = key
    self.value = value
  }
}

extension Anytype_Event.Object.Details.Set {
  public init(id: String, details: SwiftProtobuf.Google_Protobuf_Struct, subIds: [String]) {
    self.id = id
    self.details = details
    self.subIds = subIds
  }
}

extension Anytype_Event.Object.Details.Unset {
  public init(id: String, keys: [String], subIds: [String]) {
    self.id = id
    self.keys = keys
    self.subIds = subIds
  }
}

extension Anytype_Event.Object.Relation.Remove {
  public init(id: String, relationKey: String) {
    self.id = id
    self.relationKey = relationKey
  }
}

extension Anytype_Event.Object.Relation.Set {
  public init(id: String, relationKey: String, relation: Anytype_Model_Relation) {
    self.id = id
    self.relationKey = relationKey
    self.relation = relation
  }
}

extension Anytype_Event.Object.Relations.Amend {
  public init(id: String, relations: [Anytype_Model_Relation]) {
    self.id = id
    self.relations = relations
  }
}

extension Anytype_Event.Object.Relations.Remove {
  public init(id: String, keys: [String]) {
    self.id = id
    self.keys = keys
  }
}

extension Anytype_Event.Object.Relations.Set {
  public init(id: String, relations: [Anytype_Model_Relation]) {
    self.id = id
    self.relations = relations
  }
}

extension Anytype_Event.Object.Remove {
  public init(ids: [String]) {
    self.ids = ids
  }
}

extension Anytype_Event.Object.Show {
  public init(
    rootID: String, blocks: [Anytype_Model_Block], details: [Anytype_Event.Object.Details.Set], type: Anytype_Model_SmartBlockType, objectTypes: [Anytype_Model_ObjectType],
    relations: [Anytype_Model_Relation], restrictions: Anytype_Model_Restrictions
  ) {
    self.rootID = rootID
    self.blocks = blocks
    self.details = details
    self.type = type
    self.objectTypes = objectTypes
    self.relations = relations
    self.restrictions = restrictions
  }
}

extension Anytype_Event.Object.Show.RelationWithValuePerObject {
  public init(objectID: String, relations: [Anytype_Model_RelationWithValue]) {
    self.objectID = objectID
    self.relations = relations
  }
}

extension Anytype_Event.Object.Subscription.Add {
  public init(id: String, afterID: String, subID: String) {
    self.id = id
    self.afterID = afterID
    self.subID = subID
  }
}

extension Anytype_Event.Object.Subscription.Counters {
  public init(total: Int64, nextCount: Int64, prevCount: Int64, subID: String) {
    self.total = total
    self.nextCount = nextCount
    self.prevCount = prevCount
    self.subID = subID
  }
}

extension Anytype_Event.Object.Subscription.Position {
  public init(id: String, afterID: String, subID: String) {
    self.id = id
    self.afterID = afterID
    self.subID = subID
  }
}

extension Anytype_Event.Object.Subscription.Remove {
  public init(id: String, subID: String) {
    self.id = id
    self.subID = subID
  }
}

extension Anytype_Event.Ping {
  public init(index: Int32) {
    self.index = index
  }
}

extension Anytype_Event.Process.Done {
  public init(process: Anytype_Model.Process) {
    self.process = process
  }
}

extension Anytype_Event.Process.New {
  public init(process: Anytype_Model.Process) {
    self.process = process
  }
}

extension Anytype_Event.Process.Update {
  public init(process: Anytype_Model.Process) {
    self.process = process
  }
}

extension Anytype_Event.Status.Thread {
  public init(summary: Anytype_Event.Status.Thread.Summary, cafe: Anytype_Event.Status.Thread.Cafe, accounts: [Anytype_Event.Status.Thread.Account]) {
    self.summary = summary
    self.cafe = cafe
    self.accounts = accounts
  }
}

extension Anytype_Event.Status.Thread.Account {
  public init(id: String, name: String, imageHash: String, online: Bool, lastPulled: Int64, lastEdited: Int64, devices: [Anytype_Event.Status.Thread.Device]) {
    self.id = id
    self.name = name
    self.imageHash = imageHash
    self.online = online
    self.lastPulled = lastPulled
    self.lastEdited = lastEdited
    self.devices = devices
  }
}

extension Anytype_Event.Status.Thread.Cafe {
  public init(status: Anytype_Event.Status.Thread.SyncStatus, lastPulled: Int64, lastPushSucceed: Bool, files: Anytype_Event.Status.Thread.Cafe.PinStatus) {
    self.status = status
    self.lastPulled = lastPulled
    self.lastPushSucceed = lastPushSucceed
    self.files = files
  }
}

extension Anytype_Event.Status.Thread.Cafe.PinStatus {
  public init(pinning: Int32, pinned: Int32, failed: Int32, updated: Int64) {
    self.pinning = pinning
    self.pinned = pinned
    self.failed = failed
    self.updated = updated
  }
}

extension Anytype_Event.Status.Thread.Device {
  public init(name: String, online: Bool, lastPulled: Int64, lastEdited: Int64) {
    self.name = name
    self.online = online
    self.lastPulled = lastPulled
    self.lastEdited = lastEdited
  }
}

extension Anytype_Event.Status.Thread.Summary {
  public init(status: Anytype_Event.Status.Thread.SyncStatus) {
    self.status = status
  }
}

extension Anytype_Event.User.Block.Join {
  public init(account: Anytype_Event.Account) {
    self.account = account
  }
}

extension Anytype_Event.User.Block.Left {
  public init(account: Anytype_Event.Account) {
    self.account = account
  }
}

extension Anytype_Event.User.Block.SelectRange {
  public init(account: Anytype_Event.Account, blockIdsArray: [String]) {
    self.account = account
    self.blockIdsArray = blockIdsArray
  }
}

extension Anytype_Event.User.Block.TextRange {
  public init(account: Anytype_Event.Account, blockID: String, range: Anytype_Model_Range) {
    self.account = account
    self.blockID = blockID
    self.range = range
  }
}

extension Anytype_Model.Process {
  public init(id: String, type: Anytype_Model.Process.TypeEnum, state: Anytype_Model.Process.State, progress: Anytype_Model.Process.Progress) {
    self.id = id
    self.type = type
    self.state = state
    self.progress = progress
  }
}

extension Anytype_Model.Process.Progress {
  public init(total: Int64, done: Int64, message: String) {
    self.total = total
    self.done = done
    self.message = message
  }
}

extension Anytype_ResponseEvent {
  public init(messages: [Anytype_Event.Message], contextID: String, traceID: String) {
    self.messages = messages
    self.contextID = contextID
    self.traceID = traceID
  }
}
