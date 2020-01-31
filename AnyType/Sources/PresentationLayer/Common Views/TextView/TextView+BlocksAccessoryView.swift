//
//  TextView+BlocksAccessoryView.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 10.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

extension TextView {
    enum BlockToolbar {}
}

// MARK: BlockToolbar
extension TextView.BlockToolbar {
    class AccessoryView: UIView {
        // MARK: Aliases
        typealias BaseToolbarView = TextView.BaseToolbarView
        typealias Style = TextView.Style
        // MARK: Variables
        var style: Style = .default
        var model: ViewModel = .init()
        var userResponse: AnyCancellable?

        // MARK: Updates
        func update(state: State) {
            func button(for state: State) -> UIButton? {
                switch state {
                case .unknown: return nil
                case .addBlock: return self.addBlockButton
                case .turnIntoBlock: return self.turnIntoBlockButton
                case .changeColor: return self.changeColorButton
                case .editBlock: return self.editActionsButton
                }
            }

            let selectedButton = button(for: state)
            let otherButtons = [addBlockButton, turnIntoBlockButton, changeColorButton, editActionsButton].filter { $0 != selectedButton }

            UIView.animate(withDuration: 0.3) {
                for button in otherButtons {
                    button?.backgroundColor = self.style.normalColor()
                }
                selectedButton?.backgroundColor = self.style.highlightedColor()
            }
        }

        // MARK: Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }

        // MARK: Actions
        @objc func processAddBlock() {
            process(.addBlock)
        }

        @objc func processTurnIntoBlock() {
            process(.turnIntoBlock)
        }

        @objc func processChangeColor() {
            process(.changeColor)
        }

        @objc func processEditActions() {
            process(.editBlock)
        }
        
        @objc func processDismissKeyboard() {
            process(.keyboardDismiss)
        }

        func process(_ action: Action) {
            self.model.process(action)
        }

        // MARK: Public API Configurations
        // something that we should put in public api.

        func setupCustomization() {
            self.backgroundColor = self.style.backgroundColor()
            
            for button in [addBlockButton, turnIntoBlockButton, changeColorButton, editActionsButton, dismissKeyboardButton] {
                button?.tintColor = self.style.normalColor()
            }

            self.addBlockButton.addTarget(self, action: #selector(Self.processAddBlock), for: .touchUpInside)
            self.turnIntoBlockButton.addTarget(self, action: #selector(Self.processTurnIntoBlock), for: .touchUpInside)
            self.changeColorButton.addTarget(self, action: #selector(Self.processChangeColor), for: .touchUpInside)
            self.editActionsButton.addTarget(self, action: #selector(Self.processEditActions), for: .touchUpInside)
            self.dismissKeyboardButton.addTarget(self, action: #selector(Self.processDismissKeyboard), for: .touchUpInside)
        }

        func setupInteraction() {
            self.userResponse = self.model.$userResponse.dropFirst().sink { (state) in
                print("Value! \(state)")
                self.update(state: state)
            }
        }

        // MARK: Setup
        func setup() {
            self.setupUIElements()
            self.addLayout()
            self.setupCustomization()
            self.setupInteraction()
        }

        // MARK: UI Elements
        private var addBlockButton: UIButton!
        private var turnIntoBlockButton: UIButton!

        private var changeColorButton: UIButton!
        private var editActionsButton: UIButton!
        private var dismissKeyboardButton: UIButton!

        private var toolbarView: BaseToolbarView!
        private var contentView: UIView!

        // MARK: Setup UI Elements
        func setupUIElements() {            
            self.autoresizingMask = .flexibleHeight
            self.addBlockButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Blocks/AddBlock"), for: .normal)
                return view
            }()

            self.turnIntoBlockButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Blocks/TurnIntoBlock"), for: .normal)
                return view
            }()
            
            self.changeColorButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Blocks/ChangeColor"), for: .normal)
                return view
            }()

            self.editActionsButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Blocks/EditActions"), for: .normal)
                return view
            }()
            
            self.dismissKeyboardButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/General/Keyboard"), for: .normal)
                return view
            }()
            
            self.toolbarView = {
                let view = BaseToolbarView()
                return view
            }()

            for view in [addBlockButton, turnIntoBlockButton].compactMap({$0}) {
                toolbarView.leftStackView.addArrangedSubview(view)
            }

            for view in [changeColorButton, editActionsButton, dismissKeyboardButton].compactMap({$0}) {
                toolbarView.rightStackView.addArrangedSubview(view)
            }
            
            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()

            self.contentView.addSubview(self.toolbarView)
            self.addSubview(self.contentView)
        }

        // MARK: Layout
        func addLayout() {
            if let view = self.contentView, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }
            if let view = self.toolbarView, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }
        }

        override var intrinsicContentSize: CGSize {
            return .zero
        }
    }
}

// MARK: ViewModel
extension TextView.BlockToolbar {
    // MARK: Action
    enum Action {
        case unknown
        case addBlock
        case turnIntoBlock
        case changeColor
        case editBlock
        case keyboardDismiss
    }
    // MARK: State
    enum State {
        case unknown
        case addBlock
        case turnIntoBlock
        case changeColor
        case editBlock
    }
    struct UserAction {
        var action: Action = .unknown
        var view: UIView?
        static var zero = Self.init()
    }
    
    // MARK: ViewModel
    class ViewModel: NSObject, ObservableObject {
        // MARK: Initialization
        override init() {
            self.turnIntoBlockViewModel = .init()
            self.addBlockViewModel = .init()
            self.changeColorViewModel = .init()
            self.editActionsViewModel = .init()
            super.init()
            self.setup()
        }

        // MARK: Setup
        func setup() {
            // WARN: Don't call this function outside of `.init()`
            // NOTE: We should drop first notification in case of setup() function in `.init()`
            let addBlock = self.addBlockViewModel.value.dropFirst().map { value -> UnderlyingAction? in
                value.flatMap{.addBlock(UnderlyingAction.BlockType.convert($0))}
            }
            let turnIntoBlock = self.turnIntoBlockViewModel.value.dropFirst().map { value -> UnderlyingAction? in
                value.flatMap{.turnIntoBlock(UnderlyingAction.BlockType.convert($0))}
            }
            let changeColor = self.changeColorViewModel.$value.dropFirst().map { value -> UnderlyingAction? in
                UnderlyingAction.ChangeColor.convert((value.textColor, value.backgroundColor)).flatMap(UnderlyingAction.changeColor)
            }
            let editBlock = self.editActionsViewModel.$value.dropFirst().map { value -> UnderlyingAction? in
                value.flatMap{.editBlock(UnderlyingAction.EditBlock.convert($0))}
            }
            
            self.allInOneStreamDescription = Publishers.Merge4(addBlock, turnIntoBlock, changeColor, editBlock).sink { value in
                print("UnderlyingAction! \(String(describing: value))")
            }
            self.allInOneStream = Publishers.Merge4(addBlock, turnIntoBlock, changeColor, editBlock).subscribe(self.allInOnePublisher)
        }

        // MARK: Publishers
        @Published fileprivate var userResponse: State = .unknown
        @Published var userAction: UserAction = .zero

        // MARK: Streams
        private var allInOneStreamDescription: AnyCancellable?
        private var allInOneStream: AnyCancellable?
        var allInOnePublisher: PassthroughSubject<UnderlyingAction?, Never> = .init()

        // MARK: ViewModels
        @ObservedObject private var turnIntoBlockViewModel: TurnIntoBlock.ViewModel
        @ObservedObject private var addBlockViewModel: AddBlock.ViewModel
        @ObservedObject private var changeColorViewModel: ChangeColor.ViewModel
        @ObservedObject private var editActionsViewModel: EditActions.ViewModel

        // MARK: Private Setters
        fileprivate func process(_ action: Action) {            
            switch action {
            case .unknown: return
            case .addBlock: self.userAction = .init(action: action, view: AddBlock.InputViewBuilder.createView(self._addBlockViewModel))
            case .turnIntoBlock: self.userAction = .init(action: action, view: TurnIntoBlock.InputViewBuilder.createView(self._turnIntoBlockViewModel))
            case .changeColor: self.userAction = .init(action: action, view: ChangeColor.InputViewBuilder.createView(self._changeColorViewModel))
            case .editBlock: self.userAction = .init(action: action, view: EditActions.InputViewBuilder.createView(self._editActionsViewModel))
            case .keyboardDismiss: self.userAction = .init(action: .keyboardDismiss, view: nil)
            }
        }
    }
}

// MARK: These actions are only blueprints.
// Supposeedly, that we have to move them somewhere on domain level.
// So, now we have to move it somewhere.
// But where?...
// These entries are coming from user actions.
// So, they are nice to be there, right?...

extension TextView.BlockToolbar {
    enum UnderlyingAction {
        enum BlockType {
            // TODO: Add existences or invert dependencies by moving BlocksTypes here?
            typealias Text = AddBlock.BlocksTypes.Text
            typealias List = AddBlock.BlocksTypes.List
            typealias Media = AddBlock.BlocksTypes.Media
            typealias Tool = AddBlock.BlocksTypes.Tool
            typealias Other = AddBlock.BlocksTypes.Other
            case text(Text)
            case list(List)
            case media(Media)
            case tool(Tool)
            case other(Other)
            static func convert(_ type: TextView.BlockToolbar.AddBlock.BlocksTypes) -> Self {
                switch type {
                case let .text(value): return .text(value)
                case let .list(value): return .list(value)
                case let .media(value): return .media(value)
                case let .tool(value): return .tool(value)
                case let .other(value): return .other(value)
                }
            }
        }
        enum EditBlock {
            case delete
            case duplicate
            case undo
            case redo
            static func convert(_ type: TextView.BlockToolbar.EditActions.Action) -> Self {
                switch type {
                case .delete: return .delete
                case .duplicate: return .duplicate
                case .undo: return .undo
                case .redo: return .redo
                }
            }
        }
        enum ChangeColor {
            case textColor(UIColor)
            case backgroundColor(UIColor)
            // TODO: Add type that wraps textColor and backgroundColor like this type.
            static func convert(_ type: (UIColor?, UIColor?)) -> Self? {
                if let first = type.0 {
                    return .textColor(first)
                }
                else if let second = type.1 {
                    return .backgroundColor(second)
                }
                return nil
            }
        }
        case addBlock(BlockType), turnIntoBlock(BlockType), changeColor(ChangeColor), editBlock(EditBlock)
    }
}
