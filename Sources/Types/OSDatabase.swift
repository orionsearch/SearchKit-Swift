//
//  OSDatabase.swift
//  SearchKit-Swift
//
//  Created by Arthur Guiot on 6/3/19.
//  Copyright © 2019 Arthur Guiot. All rights reserved.
//

import Foundation

/// `OSDatabase` is an object that enables OrionSearch to interact with any databases. It also contains a "keywords cache" that is used for rewriting the query. The cache will be auto-configured with the `configure` method, but if you already ran this function, you can just restore the cache by initiating the class with it:
///
/// ```js
/// let db1 = OSDatabase()
/// db1.configure(main: "title", secondary: "content")
///
/// let db2 = new OSDatabase(db1.keywordsCache) // same as db1
/// ```
///
/// > **⚠️ Note about database structure:**
/// Every database should have a column named `keywords` that will be used by OrionSearch to filter records.
///
/// ### Set up bindings for your DB
/// In this section, we'll show you a detailed example with the SQLite 3 database.
/// ```js
/// const db = new OSDatabase() // Creates the object
///
/// /* Implementing methods */
/// db.setPlugin(
///     (key, contains, range) => { // Select method
///         const r = range == null ? [0, Number.MAX_SAFE_INTEGER] : range  // Creates a range
///         let rows = []
///         if (contains == null) { // If OrionSearch needs to query everything. Used for the configure method.
///             const query = data.prepare(`SELECT rowid, * FROM main WHERE rowid BETWEEN ${r[0]} AND ${r[1]}`)
///             rows = query.all()
///         } else { // Otherwise
///             const query = data.prepare(`SELECT rowid, * FROM main WHERE ${key} LIKE "%${contains}%" AND rowid BETWEEN ${r[0]} AND ${r[1]}`)
///             rows = query.all()
///         }
///         let out = []
///         rows.forEach(row => { // Setting the main key.
///             const record = new OSRecord(row) // Creating a record based on the retrieved data.
///             record.main("headlines") // "headlines" is now the main column for this record.
///             out.push(record)
///         })
///         return out // Returning all the records
///     },
///     add => { // Add a record
///         const query = data.prepare(`INSERT INTO main VALUES (${add.values})`)
///         query.run()
///     },
///     (keywords, record) => { // Manage "keywords" column. It will insert an array of records in the desired row.
///         const keyQuery = data.prepare(`UPDATE main SET keywords = "${[...keywords].join(' ')}" WHERE rowid = ${record.data.rowid};`)
///         keyQuery.run()
///     }
/// )
/// ```
public class OSDatabase {
    /// The keyword cache. Used to transfer database cache.
    public var keywordsCache: Set<String>
    var data: [OSRecord] = []
    
    public init(cache: Set<String> = Set()) {
        keywordsCache = cache
    }
    
    var main: String = ""
    var secondary: String?
    public func configure(main: String, secondary: String? = nil, lang: String = "en", completion: (() -> Void)? = nil) {
        self.main = main
        self.secondary = secondary
        
    }
    
    var sFunction: ((String, String?) -> [OSRecord])?
    public func select(contains: String? = nil, key: String = "keywords", range: Range<Int>? = nil) -> [OSRecord] {
        if let s = sFunction {
            return s(key, contains)
        } else {
            return select(key: key, contains: contains)
        }
    }
    private func select(key: String, contains: String?) -> [OSRecord] {
        guard let contains = contains else {
            return data
        }
        var out = [OSRecord]()
        data.forEach { (record) in
            if key == "keywords" {
                let entry = record.data[key] as! Set<String>
                if entry.contains(contains) {
                    out.append(record)
                }
            } else {
                let entry = record.data[key] as! String
                let t = entry.lowercased().split(separator: " ").map { String($0) }
                if t.contains(contains) {
                    out.append(record)
                }
            }
        }
        return out
    }
}
