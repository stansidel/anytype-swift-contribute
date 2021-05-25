//
//  DocumentCoverView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 25.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

final class DocumentCoverView: UIView {
    
    // MARK: - Views

    private let imageView = UIImageView()
    private lazy var imageLoader = ImageLoader().configured(imageView)
    
    // MARK: - Variables
    
    private weak var viewModel: DocumentDetailsViewModel?

    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
    
}

// MARK: - ConfigurableView

extension DocumentCoverView: ConfigurableView {
    
    func configure(model: DocumentCover) {
        switch model {
        case let .imageId(imageId):
            showImageWithId(imageId)
        case let .color(color):
            showImageBasedOnColor(color)
        }
    }
    
    private func showImageWithId(_ imageId: String) {
        imageView.removeAllSubviews()
        
        let parameters = ImageParameters(width: .default)
        imageLoader.update(
            imageId: imageId,
            parameters: parameters,
            placeholder: PlaceholderImageBuilder.placeholder(
                with: ImageGuideline(
                    size: CGSize(width: 1, height: Constants.height)
                ),
                color: UIColor.grayscale10
            )
        )
    }
    
    private func showImageBasedOnColor(_ color: UIColor) {
        imageView.removeAllSubviews()
        
        imageView.image = PlaceholderImageBuilder.placeholder(
            with: ImageGuideline(
                size: CGSize(width: 1, height: Constants.height)
            ),
            color: color
        )
    }
    
}

// MARK: - Private extension

private extension DocumentCoverView {
    
    func setupView() {
        // TODO: - load image with size of `ImageView`
        imageView.contentMode = .scaleToFill
        
        setupLayout()
    }
    
    func setupLayout() {
        addSubview(imageView)
        imageView.pinAllEdges(to: self)
        
        layoutUsing.anchors {
            $0.height.equal(to: Constants.height)
        }
    }
    
}

private extension DocumentCoverView {
    
    enum Constants {
        static let height: CGFloat = 224
    }
    
}
