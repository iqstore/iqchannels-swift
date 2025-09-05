import UIKit
import SwiftUI

final class AttributeTextManager {
    
    static let shared: AttributeTextManager = .init()
    
    private init() {}
    
    func getString(from markdown: String, textColor: UIColor, fontSize: CGFloat, alingment: TextAlignment, isBold: Bool, isItalic: Bool) -> (NSAttributedString, [Link]) {
        var formattedMarkdown = markdown.replacingOccurrences(of: "\\n", with: "\n")
        
        
        var symbolicTraits: UIFontDescriptor.SymbolicTraits = []
        if isBold {
            symbolicTraits.insert(.traitBold)
        }
        if isItalic {
            symbolicTraits.insert(.traitItalic)
        }
        var font = UIFont.systemFont(ofSize: fontSize)

        if let descriptor = font.fontDescriptor.withSymbolicTraits(symbolicTraits) {
            font = UIFont(descriptor: descriptor, size: fontSize)
        }
        let textAlignments: [TextAlignment: NSTextAlignment] = [
            .leading: .left,
            .center: .center,
            .trailing: .right
        ]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignments[alingment] ?? .left
        
        let attributedString = NSMutableAttributedString(string: formattedMarkdown)
        var linkRanges: [Link] = []
        attributedString.setAttributes([
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ], range: .init(location: 0, length: (formattedMarkdown as NSString).length))
        
        // Define patterns for markdown
        let patterns: [(String, [NSAttributedString.Key: Any])] = [
            ("\\\\\\*(.*?)\\\\\\*", [.font: UIFont.systemFont(ofSize: fontSize, weight: .bold)]),
            ("\\\\\\_(.*?)\\\\\\_", [.font: UIFont.italicSystemFont(ofSize: fontSize)]),
            ("`(.*?)`", [.font: UIFont(name: "Courier", size: UIFont.systemFontSize)!]),
            ("\\[([^\\]]+)\\]\\(([^\\)]+)\\)", [:])
        ]
        
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: textColor,
            .underlineColor: textColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        // Function to apply attributes to matches
        func applyAttributes(to matches: [NSTextCheckingResult], in text: NSMutableAttributedString, attributes: [NSAttributedString.Key: Any], pattern: String) {
            for match in matches.reversed() {
                if pattern == "\\[([^\\]]+)\\]\\(([^\\)]+)\\)" {
                    if match.numberOfRanges == 3 {
                        let linkTextRange = match.range(at: 1)
                        let linkURLRange = match.range(at: 2)
                        if let _ = text.attributedSubstring(from: linkTextRange).string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                           let linkURL = text.attributedSubstring(from: linkURLRange).string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                            let urlString = linkURL.hasPrefix("http") ? linkURL : "http://\(linkURL)"
                            linkRanges.append((urlString, linkTextRange))
                            text.setAttributes(linkAttributes, range: linkTextRange)
                            text.replaceCharacters(in: NSRange(location: match.range.location, length: match.range.length), with: text.attributedSubstring(from: linkTextRange))
                        }

                    }
                } else {
                    text.addAttributes(attributes, range: match.range(at: 1))
                    let fullRange = match.range
                    let replacementText = text.attributedSubstring(from: match.range(at: 1))
                    text.replaceCharacters(in: fullRange, with: replacementText)
                }
            }
        }
        
        func formatStringWithList(_ input: String) -> String {
            let lines = input.components(separatedBy: "\n")
            var formattedLines = [String]()

            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedLine.hasPrefix("*") {
                    let text = trimmedLine.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
                    formattedLines.append("• \(text)")
                } else if trimmedLine.first?.isNumber ?? false {
                    formattedLines.append(trimmedLine)
                }
            }

            return formattedLines.joined(separator: "\n")
        }
        
        func isList(_ input: String) -> Bool {
            let pattern = "(\\\n\\*|\\\n\\d+\\.)"
            
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            
            return (regex?.firstMatch(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))) != nil
        }
        
        for (pattern, attributes) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let matches = regex.matches(in: attributedString.string, options: [], range: NSRange(location: 0, length: attributedString.length))
                applyAttributes(to: matches, in: attributedString, attributes: attributes, pattern: pattern)
            } catch {
                print("Invalid regex pattern: \(pattern)")
            }
        }
        
        // Handle generic links
        let linkPatterns = [
//            "^(https?:\\/\\/|www\\.)[A-Za-z0-9.-]+\\.[A-Za-z]{2,}(\\:[0-9]{1,5})?(\\/.*)?$"
            #"https?:\/\/[^\s/$.?#].[^\s]*"#
        ]
        
        for pattern in linkPatterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let matches = regex.matches(in: attributedString.string, options: [], range: NSRange(location: 0, length: (attributedString.string as NSString).length))
                for match in matches.reversed() {
                    let linkRange = match.range(at: 0)
                    let linkText = attributedString.attributedSubstring(from: linkRange).string
                    let urlString = linkText.hasPrefix("http") ? linkText : "http://\(linkText)"
                    linkRanges.append((urlString, linkRange))
                    attributedString.setAttributes(linkAttributes, range: linkRange)

                }
            } catch {
                print("Invalid regex pattern: \(pattern)")
            }
        }
        
        return (attributedString, linkRanges)
    }
}
