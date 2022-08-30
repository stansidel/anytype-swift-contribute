import Foundation
import Combine
import BlocksModels

protocol BookmarkServiceProtocol {
    func fetchBookmark(contextID: BlockId, blockID: BlockId, url: String)
    func createAndFetchBookmark(
        contextID: BlockId,
        targetID: BlockId,
        position: BlockPosition,
        url: String
    )
    func createBookmarkObject(url: String, completion: @escaping (_ withError: Bool) -> Void)
    func fetchBookmarkContent(bookmarkId: BlockId, url: String)
}
