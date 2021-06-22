
import UIKit
import Combine
import BlocksModels


// MARK: - TextBlockContentView

final class TextBlockContentView: UIView & UIContentView {
    // MARK: Constants
    private enum LayoutConstants {
        static let insets: UIEdgeInsets = .init(top: 1, left: 20, bottom: -1, right: -20)
        static let backgroundViewInsets: UIEdgeInsets = .init(top: 1, left: 0, bottom: -1, right: 0)
        static let selectionViewInsets: UIEdgeInsets = .init(top: 1, left: 8, bottom: -1, right: -8)
    }
    
    private enum Constants {
        enum Text {
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
        }
        
        enum Quote {
            static let viewWidth: CGFloat = 14
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 14, bottom: 4, right: 8)
        }
        
        enum Bulleted {
            static let viewSide: CGFloat = 28
            static let dotTopOffset: CGFloat = 11
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 0, bottom: 4, right: 8)
            static let dotImageName: String = "TextEditor/Style/Text/Bulleted/Bullet"
        }
        
        enum Checkbox {
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 8)
            static let checkedImageName: String = "TextEditor/Style/Text/Checkbox/checked"
            static let uncheckedImageName: String = "TextEditor/Style/Text/Checkbox/unchecked"
            static let buttonTag = 1
            static let buttonTopOffset: CGFloat = 2
        }
        
        enum Numbered {
            static let labelTopOffset: CGFloat = 5
            static let leadingViewWidth: CGFloat = 27
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 1, bottom: 4, right: 8)
            static let numberToPlaceTextLeft: Int = 20
        }
        
        enum Toggle {
            static let textContainerInsets: UIEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 8)
            static let foldedImageName = "TextEditor/Style/Text/Toggle/folded"
            static let unfoldedImageName = "TextEditor/Style/Text/Toggle/unfolded"
            static let buttonTag = 2
            static let titleEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0)
            static let desiredCreateChildButtonHeight: CGFloat = 26.5
        }
    }

    // MARK: Views

    private let topView = TopWithChildUIKitView()
    private let backgroundColorView = UIView()
    private let selectionView = UIView()

    private(set) lazy var textView: CustomTextView = {
        let actionsHandler = SlashMenuActionsHandlerImp(
            addBlockAndActionsSubject: currentConfiguration.toolbarActionSubject,
            blockActionHandler: currentConfiguration.blockActionHandler
        )
        
        let restrictions = BlockRestrictionsFactory().makeRestrictions(
            for: currentConfiguration.information.content.type
        )
        
        let mentionsSelectionHandler = { [weak self] (mention: MentionObject) in
            guard let self = self,
                  let mentionSymbolPosition = self.textView.inputSwitcher.accessoryViewTriggerSymbolPosition,
                  let previousToMentionSymbol = self.textView.textView.position(from: mentionSymbolPosition,
                                                                                offset: -1),
                  let caretPosition = self.textView.textView.caretPosition() else { return }
            self.textView.textView.insert(mention, from: previousToMentionSymbol, to: caretPosition)
            self.currentConfiguration.setupMentionsInteraction(self.textView)
            if let attributedText = self.textView.textView.attributedText {
                self.currentConfiguration.viewModel.send(textViewAction: .textView(.changeText(attributedText)))
            }
        }
        
        let autocorrect = currentConfiguration.information.content.type == .text(.title) ? false : true
        let options = CustomTextView.Options(
            createNewBlockOnEnter: restrictions.canCreateBlockBelowOnEnter,
            autocorrect: autocorrect
        )

        let blockActionBuilder = BlockActionsBuilder(restrictions: restrictions)
        return CustomTextView(
            options: options,
            menuItemsBuilder: blockActionBuilder,
            slashMenuActionsHandler: actionsHandler,
            mentionsSelectionHandler: mentionsSelectionHandler
        )
    }()

    private lazy var createChildBlockButton: UIButton = {
        let button: UIButton = .init(primaryAction: .init(handler: { [weak self] _ in
            guard let self = self else { return }

            let block = self.currentConfiguration.viewModel.block
            self.createChildBlockButton.isHidden = true
            self.currentConfiguration.viewModel.send(
                action: .textView(
                    model: block,
                    action: .textView(.keyboardAction(.pressKey(.enterAtTheEndOfContent)))
                )
            )
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(.init(string: NSLocalizedString("Toggle empty Click and drop block inside",
                                                                  comment: ""),
                                        attributes: [.font: UIFont.bodyFont,
                                                     .foregroundColor: UIColor.secondaryTextColor]),
                                  for: .normal)
        button.contentHorizontalAlignment = .leading
        button.isHidden = true
        button.titleEdgeInsets = Constants.Toggle.titleEdgeInsets
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: Configuration

    private var currentConfiguration: TextBlockContentConfiguration

    var configuration: UIContentConfiguration {
        get { self.currentConfiguration }
        set {
            guard let configuration = newValue as? TextBlockContentConfiguration else { return }
            self.apply(configuration: configuration)
        }
    }

    // Combine Subscriptions
    private var subscriptions: Set<AnyCancellable> = .init()

    // MARK: - Initialization

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(configuration: TextBlockContentConfiguration) {
        self.currentConfiguration = configuration

        super.init(frame: .zero)

        self.setupViews()
        self.applyNewConfiguration()
    }

    // MARK: - Setup views

    private func setupViews() {
        self.topView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(topView)
        stackView.addArrangedSubview(createChildBlockButton)

        selectionView.layer.cornerRadius = 6
        selectionView.layer.cornerCurve = .continuous
        selectionView.isUserInteractionEnabled = false
        selectionView.clipsToBounds = true

        addSubview(backgroundColorView)
        addSubview(stackView)
        addSubview(selectionView)

        _ = self.topView.configured(leftChild: .empty())
        _ = self.topView.configured(textView: self.textView)

        self.setupLayout()
    }

    private func setupLayout() {
        stackView.addArrangedSubview(topView)
        stackView.addArrangedSubview(createChildBlockButton)

        createChildBlockButton.heightAnchor.constraint(equalToConstant: 26.5).isActive = true

        stackView.pinAllEdges(to: self, insets: LayoutConstants.insets)
        backgroundColorView.pinAllEdges(to: self, insets: LayoutConstants.backgroundViewInsets)
        selectionView.pinAllEdges(to: self, insets: LayoutConstants.selectionViewInsets)
    }

    // MARK: - Apply configuration

    private func apply(configuration: TextBlockContentConfiguration) {
        guard self.currentConfiguration != configuration else { return }
        self.currentConfiguration = configuration
        self.applyNewConfiguration()
    }

    private func applyNewConfiguration() {
        // reset content cell to plain text
        setupForText()
        subscriptions.removeAll()

        textView.delegate = nil
        // We don't want to handle delegate methods after 'attributedText = nil' it cause side effects
        textView.textView.delegate = nil
        // it's important to clean old attributed string
        textView.textView.attributedText = nil
        textView.textView.delegate = textView
        textView.delegate = currentConfiguration.textViewDelegate
        textView.userInteractionDelegate = currentConfiguration.viewModel

        guard case let .text(text) = self.currentConfiguration.information.content else { return }
        // In case of configurations is not equal we should check what exactly we should change
        // Because configurations for checkbox block and numbered block may not be equal, so we must rebuld whole view
        createChildBlockButton.isHidden = true
        textView.textView.selectedColor = nil

        switch text.contentType {
        case .title:
            self.setupForTitle()
        case .text:
            self.setupForText()
        case .toggle:
            setupForToggle()
        case .bulleted:
            self.setupForBulleted()
        case .checkbox:
            self.setupForCheckbox(checked: text.checked)
        case .numbered:
            self.setupForNumbered(number: text.number)
        case .quote:
            self.setupForQuote()
        case .header:
            self.setupForHeader1()
        case .header2:
            self.setupForHeader2()
        case .header3:
            self.setupForHeader3()
        case .header4, .code:
            break
        }

        currentConfiguration.viewModel.setFocus.sink { [weak self] focus in
            self?.textView.setFocus(focus)
        }.store(in: &subscriptions)

        currentConfiguration.viewModel.shouldResignFirstResponder.sink { [weak self] _ in
            self?.textView.shouldResignFirstResponder()
        }.store(in: &subscriptions)

        currentConfiguration.viewModel.$textViewUpdate.sink { [weak self] textUpdate in
            guard let textUpdate = textUpdate, let self = self else { return }
            let cursorPosition = self.textView.textView.selectedRange
            self.textView.apply(update: textUpdate)
            self.textView.textView.selectedRange = cursorPosition
        }.store(in: &subscriptions)

        currentConfiguration.viewModel.refreshedTextViewUpdate()


        typealias ColorConverter = MiddlewareColorConverter
        backgroundColorView.backgroundColor = ColorConverter.asUIColor(
            name: self.currentConfiguration.information.backgroundColor,
            background: true
        )

        selectionView.layer.borderWidth = 0.0
        selectionView.layer.borderColor = nil
        selectionView.backgroundColor = .clear

        if currentConfiguration.isSelected {
            selectionView.layer.borderWidth = 2.0
            selectionView.layer.borderColor = UIColor.pureAmber.cgColor
            selectionView.backgroundColor = UIColor.pureAmber.withAlphaComponent(0.1)
        }
        currentConfiguration.textViewConfigurator.configure(textView: textView)
    }
    
    private func setupForPlainText() {
        guard !self.topView.leftView.isNil else  { return }
        _ = self.topView.configured(leftChild: .empty())
        self.textView.textView.textContainerInset = Constants.Text.textContainerInsets
    }
    
    private func setupForText() {
        self.setupForPlainText()
        self.setupText(placeholer: "", font: .bodyFont)
    }
    
    private func setupForTitle() {
        self.setupForPlainText()
        self.setupText(placeholer: NSLocalizedString("Title", comment: ""), font: .titleFont)
    }
    
    private func setupForHeader1() {
        self.setupForPlainText()
        self.setupText(placeholer: NSLocalizedString("Header 1", comment: ""), font: .header1Font)
    }
    
    private func setupForHeader2() {
        self.setupForPlainText()
        self.setupText(placeholer: NSLocalizedString("Header 2", comment: ""), font: .header2Font)
    }
    
    private func setupForHeader3() {
        self.setupForPlainText()
        self.setupText(placeholer: NSLocalizedString("Header 3", comment: ""), font: .header3Font)
    }
    
    private func setupText(placeholer: String, font: UIFont) {
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor: UIColor.secondaryTextColor]

        self.textView.textView.update(placeholder: .init(string: placeholer, attributes: attributes))
        self.textView.textView.font = font
        self.textView.textView.typingAttributes = [.font: font]
        self.textView.textView.defaultFontColor = .textColor
    }
    
    private func setupForCheckbox(checked: Bool) {
        if let button = self.topView.leftView.subviews.first as? UIButton,
           button.tag == Constants.Checkbox.buttonTag {
            button.isSelected = checked
        } else {
            let button: UIButton = .init()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = Constants.Checkbox.buttonTag
            button.setImage(.init(imageLiteralResourceName: Constants.Checkbox.uncheckedImageName), for: .normal)
            button.setImage(.init(imageLiteralResourceName: Constants.Checkbox.checkedImageName), for: .selected)
            button.imageView?.contentMode = .scaleAspectFill
            button.contentVerticalAlignment = .bottom
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.isSelected = checked
            button.addAction(UIAction(handler: { [weak button, weak self] _ in
                guard let self = self, let button = button else { return }
                self.currentConfiguration.viewModel.send(textViewAction: .buttonView(.checkbox(!button.isSelected)))
            }), for: .touchUpInside)
            
            let container: UIView = .init()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(button)
            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(equalTo: button.widthAnchor),
                container.heightAnchor.constraint(greaterThanOrEqualTo: button.heightAnchor),
                button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                button.topAnchor.constraint(equalTo: container.topAnchor, constant: Constants.Checkbox.buttonTopOffset)
            ])
            _ = self.topView.configured(leftChild: container, setConstraints: true)
        }

        self.setupText(placeholer: NSLocalizedString("Checkbox placeholder", comment: ""), font: .bodyFont)
        self.textView.textView.textContainerInset = Constants.Checkbox.textContainerInsets
        // selected color
        textView.textView.selectedColor = checked ? UIColor.secondaryTextColor : nil
    }
    
    private func setupForBulleted() {
        self.setupText(placeholer: NSLocalizedString("Bulleted placeholder", comment: ""), font: .bodyFont)
        self.textView.textView.textContainerInset = Constants.Bulleted.textContainerInsets
        let isBulletedView = self.topView.leftView.subviews.first is UIImageView
        guard !isBulletedView else { return }
        
        let view: UIView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let dotView: UIImageView = .init(image: .init(imageLiteralResourceName: Constants.Bulleted.dotImageName))
        dotView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dotView)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Bulleted.viewSide),
            view.widthAnchor.constraint(equalToConstant: Constants.Bulleted.viewSide),
            dotView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.Bulleted.dotTopOffset),
            dotView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        _ = self.topView.configured(leftChild: view, setConstraints: true)
    }
    
    private func setupForNumbered(number: Int) {
        if let label = self.topView.leftView.subviews.first as? UILabel {
            label.textAlignment = number >= Constants.Numbered.numberToPlaceTextLeft ? .left : .center
            label.text = String(number) + "."
        } else {
            let label: UILabel = .init()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .bodyFont
            label.textAlignment = number >= Constants.Numbered.numberToPlaceTextLeft ? .left : .center
            label.text = String(number) + "."
            
            let container: UIView = .init()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)
            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(equalToConstant: Constants.Numbered.leadingViewWidth),
                label.widthAnchor.constraint(equalTo: container.widthAnchor),
                container.heightAnchor.constraint(greaterThanOrEqualTo: label.heightAnchor),
                label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                label.topAnchor.constraint(equalTo: container.topAnchor, constant: Constants.Numbered.labelTopOffset)
            ])
            _ = self.topView.configured(leftChild: container, setConstraints: true)
        }
        self.textView.textView.textContainerInset = Constants.Numbered.textContainerInsets
        self.setupText(placeholer: NSLocalizedString("Numbered placeholder", comment: ""), font: .bodyFont)
    }
    
    private func setupForQuote() {
        self.textView.textView.textContainerInset = Constants.Quote.textContainerInsets
        self.setupText(placeholer: NSLocalizedString("Quote placeholder", comment: ""), font: .highlightFont)
        let isQuoteViewExist = self.topView.leftView.subviews.first is QuoteBlockLeadingView
        guard !isQuoteViewExist else { return }
        let view: QuoteBlockLeadingView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: Constants.Quote.viewWidth).isActive = true
        _ = self.topView.configured(leftChild: view, setConstraints: true)
    }
    
    private func setupForToggle() {
        let toggleButton: UIButton?
        if let button = self.topView.leftView.subviews.first as? UIButton,
           button.tag == Constants.Toggle.buttonTag {
            toggleButton = button
        } else {
            let button = makeToggleButton()
            let container: UIView = .init()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(button)
            NSLayoutConstraint.activate([
                container.widthAnchor.constraint(equalTo: button.widthAnchor),
                container.heightAnchor.constraint(greaterThanOrEqualTo: button.heightAnchor),
                button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                button.topAnchor.constraint(equalTo: container.topAnchor, constant: 3)
            ])
            _ = self.topView.configured(leftChild: container, setConstraints: true)
            toggleButton = button
        }
        let toggled = currentConfiguration.viewModel.block.isToggled
        toggleButton?.isSelected = toggled
        setupText(placeholer: NSLocalizedString("Toggle placeholder", comment: ""), font: .bodyFont)
        textView.textView.textContainerInset = Constants.Toggle.textContainerInsets
        let hasNoChildren = currentConfiguration.viewModel.block.childrenIds().isEmpty
        updateCreateChildButtonState(toggled: toggled, hasChildren: !hasNoChildren)
    }
    
    private func makeToggleButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(imageLiteralResourceName: Constants.Toggle.foldedImageName), for: .normal)
        button.setImage(UIImage(imageLiteralResourceName: Constants.Toggle.unfoldedImageName), for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.addAction(UIAction(handler: { [weak self, weak button] _ in
            guard let self = self else { return }

            let blockViewModel = self.currentConfiguration.viewModel
            button?.isSelected.toggle()
            blockViewModel.update { $0.isToggled.toggle() }
            let toggled = blockViewModel.block.isToggled
            blockViewModel.send(textViewAction: .buttonView(.toggle(.toggled(toggled))))
            let oldValue = self.createChildBlockButton.isHidden
            self.updateCreateChildButtonState(toggled: toggled,
                                              hasChildren: !blockViewModel.block.childrenIds().isEmpty)
            if oldValue != self.createChildBlockButton.isHidden {
                blockViewModel.baseBlockDelegate?.blockSizeChanged()
            }
        }), for: .touchUpInside)
        button.tag = Constants.Toggle.buttonTag
        return button
    }
    
    private func updateCreateChildButtonState(toggled: Bool, hasChildren: Bool) {
        let shouldShowCreateButton = toggled && !hasChildren
        createChildBlockButton.isHidden = !shouldShowCreateButton
    }
}
