import UIKit
import SwiftUI

final class BlocksSelectionOverlayView: UIView {
    let viewModel: BlocksSelectionOverlayViewModel

    // MARK: - UI elements
    private let blocksOptionView: BlocksOptionView
    private lazy var navigationView = SelectionNavigationView(frame: .zero)
    private lazy var statusBarOverlayView = UIView()

    init(
        viewModel: BlocksSelectionOverlayViewModel,
        blocksOptionView: BlocksOptionView
    ) {
        self.viewModel = viewModel
        self.blocksOptionView = blocksOptionView

        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("unavailable initializer")
    }

    // MARK: - Override
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let isValid = subviews.contains {
            $0.hitTest(convert(point, to: $0), with: event) != nil
        }

        return isValid
    }

    // MARK: - Private
    private func setupView() {
        bindActions()
        backgroundColor = .clear

        let statusBarHeight = UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        addSubview(statusBarOverlayView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.height.equal(to: statusBarHeight)
        }

        statusBarOverlayView.backgroundColor = .white

        addSubview(navigationView) {
            $0.pin(to: self, excluding: [.bottom, .top], insets: .zero)
            $0.top.equal(to: statusBarOverlayView.bottomAnchor)
            $0.height.equal(to: 48)
        }

        let blocksOptionUIView = blocksOptionView.asUIView()
        let shadowedBlocksOptionView = RoundedShadowView(view: blocksOptionUIView, cornerRadius: 16)

        addSubview(shadowedBlocksOptionView) {
            $0.pinToSuperview(excluding: [.top], insets: .init(top: 0, left: 10, bottom: -10, right: -10))
            $0.height.equal(to: 100)
        }

        blocksOptionUIView.layer.cornerRadius = 16
        blocksOptionUIView.layer.masksToBounds = true
        shadowedBlocksOptionView.shadowLayer.fillColor = UIColor.white.cgColor
        shadowedBlocksOptionView.shadowLayer.shadowColor = UIColor.black.cgColor
        shadowedBlocksOptionView.shadowLayer.shadowOffset = .init(width: 0, height: 2)
        shadowedBlocksOptionView.shadowLayer.shadowOpacity = 0.25
        shadowedBlocksOptionView.shadowLayer.shadowRadius = 3
    }

    private func bindActions() {
        navigationView.leftButtonTap = { [unowned self] in
            viewModel.endEditingModeHandler?()
        }
    }
}

private final class SelectionNavigationView: UIView {
    var leftButtonTap: (() -> Void)?

    private lazy var titleLabel = UILabel()
    private lazy var leftButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }

    private func setupView() {
        backgroundColor = .white

        addSubview(titleLabel) {
            $0.centerX.equal(to: centerXAnchor)
            $0.centerY.equal(to: centerYAnchor)
        }

        titleLabel.text = "Awesome new text will be here"

        let leftButtonAction = UIAction(handler: { [unowned self] _ in
            leftButtonTap?()
        })
        leftButton.setTitle("Done".localized, for: .normal)
        leftButton.setTitleColor(.pureAmber, for: .normal)
        leftButton.addAction(leftButtonAction, for: .touchUpInside)

        addSubview(leftButton) {
            $0.trailing.equal(to: trailingAnchor, constant: -16)
            $0.centerY.equal(to: centerYAnchor)
        }
    }
}
