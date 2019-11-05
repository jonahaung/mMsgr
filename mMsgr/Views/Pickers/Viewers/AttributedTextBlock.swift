import UIKit

public enum AttributedTextBlock {
    case black(String)
    case heavy(String)
    case headline(String)
    case subheadline(String)
    case callout(String)
    case body(String)
    case caption1(String)
    case title3(String)
    case footnote(String)
    case list(String)
    
    var text: NSMutableAttributedString {
        let attributedString: NSMutableAttributedString
        switch self {
        case .black(let value):
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 38, weight: .heavy), .foregroundColor: UIColor.secondaryLabel]
            attributedString = NSMutableAttributedString(string: value, attributes: attributes)
        case .heavy(let value):
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 22, weight: .heavy)]
            attributedString = NSMutableAttributedString(string: value, attributes: attributes)
        case .headline(let value):
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .headline)]
            attributedString = NSMutableAttributedString(string: value, attributes: attributes)
        case .subheadline(let value):
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .subheadline)]
            attributedString = NSMutableAttributedString(string: value, attributes: attributes)
        case .callout(let value):
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .callout)]
            attributedString = NSMutableAttributedString(string: value, attributes: attributes)
        case .body(let value):
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .body)]
            attributedString = NSMutableAttributedString(string: value, attributes: attributes)
        case .footnote(let value):
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .footnote)]
            attributedString = NSMutableAttributedString(string: value, attributes: attributes)
        case .caption1(let value):
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .caption1)]
            attributedString = NSMutableAttributedString(string: value, attributes: attributes)
        case .title3(let value):
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .title3)]
            attributedString = NSMutableAttributedString(string: value, attributes: attributes)
        case .list(let value):
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .body)]
            attributedString = NSMutableAttributedString(string: "• \(value)", attributes: attributes)
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineHeightMultiple = 1
        paragraphStyle.paragraphSpacing = 5
    
        attributedString.addAttributes([.paragraphStyle: paragraphStyle, .foregroundColor: UIColor.label], range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }
}
