//
//  OSQuery.swift
//  SearchKit-Swift
//
//  Created by Arthur Guiot on 6/3/19.
//  Copyright © 2019 Arthur Guiot. All rights reserved.
//

import Foundation

/// `OSQuery` is an object that represents a search query. It makes the process of parsing and tokenizing a query without the need for user's interaction. It currently supports 57 languages (ISO 639-1):
///
/// <table><tr><td>af</td><td>ar</td><td>hy</td><td>eu</td><td>bn</td><td>br</td><td>bg</td><td>ca</td><td>zh</td><td>hr</td><td>cs</td><td>da</td><td>nl</td><td>en</td><td>eo</td><td>et</td><td>fi</td><td>fr</td><td>gl</td><td>de</td><td>el</td><td>ha</td><td>he</td><td>hi</td><td>hu</td><td>id</td><td>ga</td><td>it</td><td>ja</td><td>ko</td><td>ku</td><td>la</td><td>lt</td><td>lv</td><td>ms</td><td>mr</td><td>no</td><td>fa</td><td>pl</td><td>pt</td><td>ro</td><td>ru</td><td>sk</td><td>sl</td><td>so</td><td>st</td><td>es</td><td>sw</td><td>sv</td><td>th</td><td>tl</td><td>tr</td><td>uk</td><td>ur</td><td>vi</td><td>yo</td><td>zu</td></tr></table>
///
/// The query object can also specify which column to search in using the `keys` array. This will mostly be useful in the Quick searches, but it works on all `OrionSearch.OSSearchType`.
///
/// #### Construction
/// ```js
/// let query = OSQuery(str: "Articles about Donald Trump")
/// ```
public class OSQuery {
    /// Original string input
    public var str: String
    /// Specials column to look into
    public var keys: [String]?
    
    /// Parsed values
    ///
    /// - **Return Values**:
    ///   - filters: `[[String]]`
    ///   - keywords: `[String : Double]`
    
    public var parsed = [String: Any]()
    /// OSQuery's contructor
    ///
    /// - Parameters:
    ///   - str: The query as it was typed by the user
    ///   - lang: In which language was the user's query written?
    ///   - keys: Special column to look into. Used for Quick searches
    public init(str: String, lang: String = "en", keys: [String]? = nil) {
        self.str = str
        self.keys = keys
        
        let parsedFilters = removeAndParseFilters(text: str)
        let stri = parsedFilters.last!
        let keywords = extractKeywords(text: str, lang: lang)
        let scores = scoreKeywords(keys: keywords)
        
        parsed = [
            "filters": parsedFilters,
            "keywords": scores
        ]
    }
    
    func removeAndParseFilters(text: String) -> [[String]] {
        let regex = Regex(pattern: "\\S*:\\S*", expressionOptions: .caseInsensitive, matchingOptions: .init(rawValue: 0))
        let matches = regex.regex?.matches(in: text, options: .init(rawValue: 0), range: NSMakeRange(0, text.count))
        
        var t = text
        
        var out = [[String]]()
        matches?.forEach({ (result) in
            let a = result.range.lowerBound
            let b = result.range.upperBound
            let str = text[a...b]
            
            let split = str.split(separator: ":")
            let name = String(split[0])
            let f = String(split[1])
            out.append([name, f])
            // remove text
            t = t.replace(pattern: str, template: "")
        })
        out.append([t])
        return out
    }
    func extractKeywords(text: String, lang: String) -> [String] {
        return text.tokenize(lang: lang)
    }
    func scoreKeywords(keys: [String]) -> [String: Double] {
        let l = keys.count
        let uniq = Set(keys)
        
        var out: [String: Double] = [:]
        
        let count = uniq.map { (x) -> [Any] in
            return [x, uniq.filter({ (a) -> Bool in
                a == x
            }).count]
        }
        let dic: [String: Double] = Dictionary(uniqueKeysWithValues: count.map { ($0[0] as! String, $0[1] as! Double )})
        
        uniq.forEach { (key) in
            let n = dic[key]
            out[key] = (n ?? 0) / Double(l)
        }
        return out
    }
}
