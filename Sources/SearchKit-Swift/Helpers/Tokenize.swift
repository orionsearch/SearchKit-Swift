//
//  Tokenize.swift
//  SearchKit-Swift
//
//  Created by Arthur Guiot on 5/3/19.
//  Copyright © 2019 Arthur Guiot. All rights reserved.
//

import Foundation

extension String {
    func tokenize(lang: String = "en") -> [String] {
        let str = self.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        let tokens = str.replace(pattern: "[^\\w\\d\\s]", template: "")
                        .replace(pattern: "\\s{2,}", template: " ")
                        .split(separator: " ")
        let out = tokens.filter { (substr) -> Bool in
            let str = String(substr)
            return str.isStop(lang: lang) && str != ""
        }
        if out.count != 0 {
            return out.compactMap({ (substr) -> String in
                return String(substr)
            })
        }
        let out2 = tokens.filter({ (substr) -> Bool in
            return String(substr) != ""
        })
        return out2.compactMap({ (substr) -> String in
            return String(substr)
        })
    }
}
