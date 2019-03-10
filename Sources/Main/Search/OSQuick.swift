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
}
