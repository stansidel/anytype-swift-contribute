import ProtobufMessages

/// Response that contains events , see https://github.com/anytypeio/go-anytype-middleware/blob/master/docs/proto.md#anytype.ResponseEvent
struct MiddlewareResponse {
    let contextId: String
    let messages: [Anytype_Event.Message]

    init(_ response: Anytype_ResponseEvent) {
        self.contextId = response.contextID
        self.messages = response.messages
    }
}
