//
//  OSQuick.swift
//  SearchKit-Swift
//
//  Created by Arthur Guiot on 10/3/19.
//  Copyright © 2019 Arthur Guiot. All rights reserved.
//

import Foundation

class OSQuick {
    var query: OSQuery
    var db: OSDatabase
    var options: [String: Any]
    var completion: (OSRecord) -> Void
    
    init(query: OSQuery, db: OSDatabase, options: [String: Any], callback: @escaping (OSRecord) -> Void) {
        self.query = query
        self.db = db
        self.options = options
        self.completion = callback
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
    
    func search() {
        let keys = getKeys()
        let keywordScore = query.parsed["keywords"] as! [String : Double]
        let keywords = Array(keywordScore.keys)
        
        keys.forEach { (key) in
            keywords.forEach({ (keyword) in
                let select = self.db.select(contains: keyword, key: key)
                select.forEach({ (record) in
                    self.completion(record)
                })
            })
        }
    }
}
