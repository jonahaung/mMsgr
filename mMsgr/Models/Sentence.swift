/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

struct Sentence {

    let text: String
    let fromLanguage: String
    let toLanguage: String
    var isMyanmar: Bool { return fromLanguage == "my" }
    init(_ _text: String) {
        text = _text
        fromLanguage = _text.language ?? "en"
        toLanguage = fromLanguage == "my" ? "en" : "my"
    }

}



