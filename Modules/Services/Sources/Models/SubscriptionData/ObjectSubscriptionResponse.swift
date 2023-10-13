public struct ObjectSubscriptionResponse {
    public let records: [ObjectDetails]
    public let dependencies: [ObjectDetails]
    public let total: Int
    public let prevCount: Int
    public let nextCount: Int
}
