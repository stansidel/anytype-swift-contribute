//
//  DocumentViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

class DocumentViewModel: ObservableObject {
    private let documentService = TestDocumentService()
    private var documentHeader: DocumentHeader?
    
    // TODO: Probably we don't need it here, remove after midleware integration
    private var document: Document?
    
    @Published var error: String?
    @Published var blocksViewsBuilders: [BlockViewBuilderProtocol]?
    
    
    init(documentId: String?) {
        obtainDocument(documentId: documentId)
    }
    
    func addBlock(content: BlockType, afterBlock: Int) {
        guard let documentHeader = documentHeader else { return }
        
        let index = afterBlock + 1
        
        documentService.addBlock(content: content, by: index, for: documentHeader.id) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let newDocumentModel):
                strongSelf.createblocksViewsBuilders(document: newDocumentModel)
            case .failure(let error):
                strongSelf.error = error.localizedDescription
            }
        }
    }
    
    func moveBlock(fromIndex: Int, toIndex: Int) {
        guard var document = document else { return }
        document.blocks.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex)
        createblocksViewsBuilders(document: document)
    }
    
}
 
extension DocumentViewModel {
    
    private func obtainDocument(documentId: String?) {
        let completion = { [weak self] (result: Result<Document, Error>) in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let document):
                strongSelf.documentHeader = document.header
                strongSelf.createblocksViewsBuilders(document: document)
                strongSelf.document = document
            case .failure(let error):
                strongSelf.error = error.localizedDescription
            }
        }
        
        /// if document exists obtain it or create new one
        if let documentId = documentId {
            documentService.obtainDocument(id: documentId, completion: completion)
        } else {
            documentService.createNewDocument(completion: completion)
        }
    }
    
    // TODO: Refact when middle will be ready
    private func createblocksViewsBuilders(document: Document) {
        blocksViewsBuilders = [BlockViewBuilderProtocol]()
        
        // TODO: Maybe we need to create some fabric for resolver?
//        let resolver: (Block) -> BlockViewBuilderProtocol = { block in
//            switch block.type {
//            case .text: return TextBlockViewModel(block: block)
//            case .image: return TextBlockViewModel(block: block)
//            case .video: return TextBlockViewModel(block: block)
//            default: return TextBlockViewModel(block: block)
//            }
//        }
//        blocksViewsBuilders = document.blocks.map(resolver)
//        blocksViewsBuilders = TextBlocksViews.Supplement.Matcher.resolver(blocks: document.blocks)
        blocksViewsBuilders = BlocksViews.Supplement.BlocksSerializer.default.resolver(blocks: document.blocks)
    }
    
}
