
import NaturalLanguage

final class SentimentClassifier {
    
   let tagger: NLTagger = NLTagger(tagSchemes: [.sentimentScore])

    func predictSentiment(from text: String) -> String? {
        tagger.string = text
        let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
    
        if let raw = sentiment?.rawValue, let score = Double(raw) {
            if score < 0 {
                return "😇"
            } else if score > 0 {
                return "😠"
            }
            return nil
        }
        return nil
    }
}
