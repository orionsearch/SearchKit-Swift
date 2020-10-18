//
//  OSNormal.swift
//  SearchKit-Swift
//
//  Created by Arthur Guiot on 11/3/19.
//  Copyright © 2019 Arthur Guiot. All rights reserved.
//

import Foundation

class OSNormal {
    var query: OSQuery
    var db: OSDatabase
    var options: [String: Any]
    var completion: (OSRecord) -> Void
    
    init(query: OSQuery, db: OSDatabase, options: [String: Any], callback: @escaping (OSRecord) -> Void) {
        self.query = query
        self.db = db
        self.options = options
        self.completion = callback
        
        cacheFilters()
    }
    
    func getKeys() -> [String] {
        var set = Set<String>()
        let queryKeys = query.keys
        if let queryKeys = queryKeys {
            queryKeys.forEach({ (key) in
                set.insert(key)
            })
        } else {
            set.insert("keywords")
        }
        return Array(set)
    }
    
    func getKeywords() -> [String] {
        let keywordScore = query.parsed["keywords"] as! [String : Double]
        let keywords = Array(keywordScore.keys)
        
        let cache = Array(self.db.keywordsCache)
        
        var out = [String]()
        keywords.forEach { (key) in
            let scores = cache.map { $0.levenshtein(key) }
            
            let min = scores.min()
            
            let i = scores.firstIndex(of: min!)
            out.append(cache[i!])
        }
        return out
    }
    
    var filters = [[String]]()
    func cacheFilters() {
        let f = query.parsed["filters"] as! [[String]]
        let of = options["filters"] as! Set<String>
        filters = f.filter { of.contains($0.first ?? "") }
    }
    
    func search() {
        let keys = getKeys()
        let keywordScore = query.parsed["keywords"] as! [String : Double]
        let keywords = Array(keywordScore.keys)
        
        var records = Set<OSRecord>()
        keys.forEach { (key) in
            keywords.forEach({ (keyword) in
                let select = self.db.select(contains: keyword, key: key)
                
                select.forEach({ (record) in
                    let emplacement = record.data[key]
                    var arr = [String]()
                    
                    if let e = emplacement as? String {
                        arr = e.split(separator: " ").map { String($0) }
                    }
                    
                    let nbOfKeys = arr.map({ (k) -> Double in
                        if (keywords.contains(k)) {
                            let s = keywordScore[k]
                            return (s?.isNaN) ?? false ? 0 : s!
                        }
                        return 0
                    }).filter { $0 != 0 }.reduce(0, { (a, c) -> Double in
                        return a + c
                    }) // compute the weight for each keywords
                    
                    var br = false
                    self.filters.forEach({ (filter) in
                        guard let a = record.data[filter[0]] as? String else {
                            br = true
                            return
                        }
                        guard a.lowercased().contains(filter[1].lowercased()) else {
                            br = true
                            return
                        }
                    })
                    
                    if br == false {
                        if !records.contains(record) {
                            record.score = nbOfKeys
                            let (inserted, member) = records.insert(record)
                        }
                    }
                })
                
            })
        }
        
        var sorted = Array(records).sorted(by: { (b, a) -> Bool in
            return a.score - b.score > 0
        })
        
        let plugins = options["plugins"] as! [([OSRecord]) -> [OSRecord]]
        
        for p in plugins {
            sorted = p(sorted)
        }
        
        sorted.forEach({ (record) in
            completion(record)
        })
    }
}
