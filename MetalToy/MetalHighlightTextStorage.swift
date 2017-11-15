//
//  MetalHighlightTextStorage.swift
//  MetalToy
//
//  Created by Toni Jovanoski on 10/27/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import UIKit

extension String {
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
}

class MetalHighlightTextStorage: NSTextStorage {
    let backingStore = NSMutableAttributedString()
    var replacements: [String: [NSAttributedStringKey: Any]]!
    
    override init() {
        super.init()
        createHighlightPatterns()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var string: String {
        return backingStore.string
    }
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedStringKey : Any] {
        return backingStore.attributes(at: location, effectiveRange: range)
    }
    
    override func replaceCharacters(in range: NSRange, with str: String) {
        print("replaceCharacters:\(range) with str: \(str)")
        
        let editActions = NSTextStorageEditActions(rawValue: NSTextStorageEditActions.editedAttributes.rawValue | NSTextStorageEditActions.editedCharacters.rawValue)
        
        beginEditing()
        backingStore.replaceCharacters(in: range, with: str)
        edited(editActions, range: range, changeInLength: (str as NSString).length - range.length)
        endEditing()
    }
    
    override func setAttributes(_ attrs: [NSAttributedStringKey : Any]?, range: NSRange) {
        print("setAttributes: range: \(range)  attr: \(String(describing: attrs))")
        
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    func applyStylesToRange(searchRange: NSRange) {
        let normalAttrs = [NSAttributedStringKey.font : UIFont(name: "Menlo-Regular", size: 12) as Any]
        self.setAttributes(normalAttrs, range: NSMakeRange(0, length))
        
        guard let substring = backingStore.string.substring(with: searchRange) else { return }
        
        var begin = 0
        
        while true {
            let start = substring.index(substring.startIndex, offsetBy: begin)
            let end = substring.index(substring.endIndex, offsetBy: 0)
        
            guard let range = substring.range(of: "float4", options: .literal, range:start..<end, locale: nil) else { break }
            
            let lower = range.lowerBound.encodedOffset
            let upper = range.upperBound.encodedOffset
            
            let redTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.red]
            
            self.addAttributes(redTextAttributes, range: NSMakeRange(lower, upper - lower))
            
            begin = upper
        }
    }
    
    func performReplacementForRange(changedRange: NSRange) {
        var extendedRange = NSUnionRange(changedRange, NSString(string: backingStore.string).lineRange(for: NSMakeRange(changedRange.location, 0)))
        extendedRange = NSUnionRange(changedRange, NSString(string: backingStore.string).lineRange(for: NSMakeRange(NSMaxRange(changedRange), 0)))
        
        applyStylesToRange(searchRange: extendedRange)
    }
    
    override func processEditing() {
        performReplacementForRange(changedRange: self.editedRange)
        super.processEditing()
    }
    
    func createAttributesForFontStyle(style: String, withTrait trait: UIFontDescriptorSymbolicTraits) -> [NSAttributedStringKey: Any] {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.body)
        let descriptorWithTrait = fontDescriptor.withSymbolicTraits(trait)
        let font = UIFont(descriptor: descriptorWithTrait!, size: 0)
        
        return [NSAttributedStringKey.font : font]
    }
    
    func createHighlightPatterns() {
        let redTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.red]
        
        // construct a dictionary of replacements based on regexes
        replacements = [
            "(?:^|\\W)float\\d(?:$|\\W)": redTextAttributes
        ]
    }
    
    func update() {
        // update the highlight patterns
        createHighlightPatterns()
        
        // change the 'global' font
        //let bodyFont = [NSAttributedStringKey.font : UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        //let a = [NSAttributedStringKey.font: UIFont(name: "Menlo-Bold", size: 36)]
        //addAttributes(a, range: NSMakeRange(0, length))
        
        // re-apply the regex matches
        applyStylesToRange(searchRange: NSMakeRange(0, length))
    }
}
