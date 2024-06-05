import UIKit

final class AttributeTextManager {
    
    static let shared: AttributeTextManager = .init()
    
    private init() {}
    
    func getString(from markdown: String, textColor: UIColor, fontSize: CGFloat) -> (NSAttributedString, [Link]) {
        var formattedMarkdown = markdown.replacingOccurrences(of: "\\n", with: "\n")
        if isList(formattedMarkdown) {
            formattedMarkdown = formatStringWithList(formattedMarkdown)
        }
        
        let attributedString = NSMutableAttributedString(string: formattedMarkdown)
        var linkRanges: [Link] = []
        attributedString.setAttributes([
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: textColor
        ], range: .init(location: 0, length: formattedMarkdown.count))
        
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
            "(https?:\\/\\/[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*))",
            "(www\\.[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*))"
        ]
        
        for pattern in linkPatterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let matches = regex.matches(in: attributedString.string, options: [], range: NSRange(location: 0, length: attributedString.length))
                for match in matches.reversed() {
                    let linkRange = match.range(at: 1)
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
