import UIKit
import Combine
import BlocksModels


final class TextBlockContentView: UIView, BlockContentView {
    
    // MARK: - Views
    private let backgroundColorView = UIView()
    private let contentView = UIView()
    private(set) lazy var textView = CustomTextView()
    private(set) lazy var createEmptyBlockButton = EmptyToggleButtonBuilder.create { [weak self] in
        self?.actions?.createEmptyBlock()
    }
    
    private let mainStackView: UIStackView = makeMainStackView()
    private let contentStackView: UIStackView = makeContentStackView()
    
    private var topMainConstraint: NSLayoutConstraint?
    private var bottomMainConstraint: NSLayoutConstraint?
    
    private var topContentConstraint: NSLayoutConstraint?
    private var bottomContentnConstraint: NSLayoutConstraint?

    private var focusSubscription: AnyCancellable?
    weak var blockDelegate: BlockDelegate?

    private(set) var actions: TextBlockContentConfiguration.Actions?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupLayout()
    }

    func update(with configuration: TextBlockContentConfiguration) {
        applyNewConfiguration(configuration: configuration)
    }

    func update(with state: UICellConfigurationState) {
        textView.textView.isUserInteractionEnabled = state.isEditing
    }

    // MARK: - Setup views
    
    private func setupLayout() {
        contentStackView.addArrangedSubview(TextBlockIconView(viewType: .empty))
        contentStackView.addArrangedSubview(textView)

        contentView.addSubview(contentStackView) {
            topContentConstraint = $0.top.equal(to: contentView.topAnchor)
            bottomContentnConstraint = $0.bottom.equal(to: contentView.bottomAnchor)
            $0.leading.equal(to: contentView.leadingAnchor)
            $0.trailing.equal(to: contentView.trailingAnchor)
        }

        backgroundColorView.addSubview(contentView) {
            $0.pinToSuperview(insets: TextBlockLayout.contentInset)
        }

        createEmptyBlockButton.layoutUsing.anchors {
            $0.height.equal(to: 26)
        }

        mainStackView.addArrangedSubview(backgroundColorView)
        mainStackView.addArrangedSubview(createEmptyBlockButton)

        addSubview(mainStackView) {
            topMainConstraint = $0.top.equal(to: topAnchor)
            bottomMainConstraint = $0.bottom.equal(to: bottomAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
    }

    // MARK: - Apply configuration
    
    private func applyNewConfiguration(configuration: TextBlockContentConfiguration) {
        textView.textView.textStorage.setAttributedString(configuration.text.attrString)
        
        let restrictions = BlockRestrictionsBuilder.build(textContentType: configuration.content.contentType)
        
        TextBlockLeftViewStyler.applyStyle(contentStackView: contentStackView, configuration: configuration)
        TextBlockTextViewStyler.applyStyle(textView: textView, configuration: configuration, restrictions: restrictions)

        updateAllConstraint(blockTextStyle: configuration.content.contentType)
        
        textView.delegate = self
        
        let displayPlaceholder = configuration.content.contentType == .toggle && configuration.shouldDisplayPlaceholder
        createEmptyBlockButton.isHidden = !displayPlaceholder

        backgroundColorView.backgroundColor = configuration.information.backgroundColor.map { UIColor.Background.uiColor(from: $0) }

        focusSubscription = configuration.focusPublisher.sink { [weak self] focus in
            self?.textView.setFocus(focus)
        }
    }
    
    private func updateAllConstraint(blockTextStyle: BlockText.Style) {
        let mainInset = TextBlockLayout.mainInset(textBlockStyle: blockTextStyle)
        let contentInset = TextBlockLayout.contentInset(textBlockStyle: blockTextStyle)
        
        topMainConstraint?.constant = mainInset.top
        bottomMainConstraint?.constant = mainInset.bottom
        
        topContentConstraint?.constant = contentInset.top
        bottomContentnConstraint?.constant = contentInset.bottom
    }
    
}

private extension TextBlockContentView {
    
    static func makeMainStackView() -> UIStackView {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        return mainStackView
    }
    
    static func makeContentStackView() -> UIStackView {
        let contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.spacing = 4
        contentStackView.alignment = .top
        return contentStackView
    }
    
}
