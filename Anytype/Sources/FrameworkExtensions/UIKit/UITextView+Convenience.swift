
import BlocksModels
import UIKit

extension UITextView {
    var isCarretInTheBeginingOfDocument: Bool {
        guard let caretPosition = caretPosition else {
            return false
        }
        
        return offsetFromBegining(caretPosition) == 0
    }
    
    var caretPosition: UITextPosition? {
        if !isFirstResponder {
            return nil
        }
        let offset = selectedRange.location + selectedRange.length
        return position(from: beginningOfDocument, offset: offset)
    }
    
    /// Append plain string to attributed string after caret.
    /// If attributedText is empty, `typingAttributes` will be set to default.
    /// This method avoids this undesired behavior and set `typingAttributes` properly.
    ///
    /// - Parameters:
    ///   - string: String to insert
    func insertStringAfterCaret(_ string: String) {
        insertString(string, location: selectedRange.location)
    }
    
    private func insertString(_ string: String, location: Int) {
        guard !string.isEmpty, location <= attributedText.length else { return }
        if attributedText.length == 0 {
            attributedText = NSAttributedString(string: string, attributes: typingAttributes)
        } else {
            attributedText = attributedText?.attributedStringByInserting(
                string,
                at: location,
                attachmentAttributes: typingAttributes
            )
            selectedRange.location = location + string.count
        }
    }
    
    func setFocus(_ position: BlockFocusPosition) {
        let selectedRange = position.toSelectedRange(in: text)

        if let beginningSelectedTextPostion = self.position(from: beginningOfDocument, offset: selectedRange.location),
           let endSelectedTextPosition = self.position(from: beginningSelectedTextPostion, offset: selectedRange.length)
        {
            selectedTextRange = textRange(from: beginningSelectedTextPostion, to: endSelectedTextPosition)
        } else {
            selectedTextRange = textRange(from: beginningOfDocument, to: beginningOfDocument)
        }

        if !isFirstResponder && canBecomeFirstResponder {
            becomeFirstResponder()
        }
    }
    
    func textChangeType(changeTextRange: NSRange, replacementText: String) -> TextViewTextChangeType {
        if replacementText == "",  changeTextRange.location < text.count {
            return .deletingSymbols
        }
        return .typingSymbols
    }
    
    func textBeforeCaret() -> String? {
        guard let caretPosition = caretPosition,
              let range = textRange(from: beginningOfDocument, to: caretPosition)
        else {
            return nil
        }
        return text(in: range)
    }
    
    func offsetFromBegining(_ position: UITextPosition) -> Int {
        return offset(from: self.beginningOfDocument, to: position)
    }
}

extension UITextView: TextViewManagingFocus {
    func shouldResignFirstResponder() {
        resignFirstResponder()
    }

    func obtainFocusPosition() -> BlockFocusPosition? {
        guard isFirstResponder else { return nil }
        return .at(selectedRange)
    }
}
