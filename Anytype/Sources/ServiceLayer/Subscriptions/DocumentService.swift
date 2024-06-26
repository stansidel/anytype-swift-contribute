import Foundation

protocol DocumentServiceProtocol: AnyObject {
    func document(objectId: String, forPreview: Bool) -> any BaseDocumentProtocol
    func setDocument(objectId: String, forPreview: Bool) -> any SetDocumentProtocol
}

// Default arguments
extension DocumentServiceProtocol {
    func document(objectId: String) -> some BaseDocumentProtocol {
        return document(objectId: objectId, forPreview: false)
    }
    func setDocument(objectId: String) -> some SetDocumentProtocol {
        return setDocument(objectId: objectId, forPreview: false)
    }
}

final class DocumentService: DocumentServiceProtocol {
        
    private var documentCache = NSMapTable<NSString, AnyObject>.strongToWeakObjects()
    private var setDocumentCache = NSMapTable<NSString, AnyObject>.strongToWeakObjects()
    
    // MARK: - DI
    
    private let relationDetailsStorage: any RelationDetailsStorageProtocol
    private let objectTypeProvider: any ObjectTypeProviderProtocol
    
    init(relationDetailsStorage: some RelationDetailsStorageProtocol, objectTypeProvider: some ObjectTypeProviderProtocol) {
        self.relationDetailsStorage = relationDetailsStorage
        self.objectTypeProvider = objectTypeProvider
    }
    
    // MARK: - DocumentServiceProtocol
    
    func document(objectId: String, forPreview: Bool) -> some BaseDocumentProtocol {
        return internalDocument(objectId: objectId, forPreview: forPreview)
    }
    
    func setDocument(objectId: String, forPreview: Bool) -> some SetDocumentProtocol {
        
        if forPreview {
            let setDocument = createSetDocument(objectId: objectId, forPreview: forPreview)
            Task { @MainActor in
                try? await setDocument.openForPreview()
            }
            return setDocument
        }
        
        if let value = setDocumentCache.object(forKey: objectId as NSString) as? SetDocumentProtocol {
            return value
        }
        
        let setDocument = createSetDocument(objectId: objectId, forPreview: forPreview)
        setDocumentCache.setObject(setDocument, forKey: objectId as NSString)
        
        Task { @MainActor in
            try? await setDocument.open()
        }
    
        return setDocument
    }
    
    // MARK: - Private func
    
    private func internalDocument(objectId: String, forPreview: Bool) -> some BaseDocumentProtocol {
        if forPreview {
            let document = createDocument(objectId: objectId, forPreview: forPreview)
            Task { @MainActor in
                try? await document.openForPreview()
            }
            return document
        }
        
        if let value = documentCache.object(forKey: objectId as NSString) as? BaseDocumentProtocol {
            return value
        }
        
        let document = createDocument(objectId: objectId, forPreview: forPreview)
        documentCache.setObject(document, forKey: objectId as NSString)

        Task { @MainActor in
            try? await document.open()
        }
        
        return document
    }
    
    private func createDocument(objectId: String, forPreview: Bool) -> some BaseDocumentProtocol {
        return BaseDocument(objectId: objectId, forPreview: forPreview)
    }
    
    private func createSetDocument(objectId: String, forPreview: Bool) -> some SetDocumentProtocol {
        let document = createDocument(objectId: objectId, forPreview: forPreview)
        return SetDocument(
            document: document,
            blockId: nil,
            targetObjectID: nil,
            relationDetailsStorage: relationDetailsStorage,
            objectTypeProvider: objectTypeProvider
        )
    }
}
