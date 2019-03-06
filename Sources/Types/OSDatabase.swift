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
    public func configure(main: String, secondary: String? = nil, lang: String = "en", completion: ((Int, Int) -> Void)? = nil) {
        self.main = main
        self.secondary = secondary
        
        let length = select().count
        var array = [Range<Int>]()
        var i = 0;
        while i < length {
            i += 1000;
            
            let max = i + 1000 > length ? length : i + 1000
            let range = Range<Int>(uncheckedBounds: (lower: i, upper: max))
            array.append(range)
        }
        for (index, range) in array.enumerated() {
            let select = self.select(contains: nil, key: "keywords", range: range)
            select.forEach { (record) in
                var keys = Set<String>()
                let mainEntry = record.data[main] as! String
                mainEntry.tokenize().forEach({ (t) in
                    self.keywordsCache.insert(t)
                    keys.insert(t)
                })
                if let secondary = secondary {
                    let secondaryEntry = record.data[secondary] as! String
                    secondaryEntry.tokenize().forEach({ (t) in
                        self.keywordsCache.insert(t)
                        keys.insert(t)
                    })
                }
                keywords(keys: keys, record: record)
            }
            if let c = completion {
                c(array[index].lowerBound, length)
            }
        }
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
    var kFunction: ((Set<String>, OSRecord) -> Void)?
    public func keywords(keys: Set<String>, record: OSRecord) {
        if let k = kFunction {
            return k(keys, record)
        } else {
            return keyword(keys: keys, record: record)
        }
    }
    private func keyword(keys: Set<String>, record: OSRecord) {
        let i = data.firstIndex { $0 == record }
        var keywords = data[i!].data["keywords"] as? Set<String>
        if keywords == nil {
            data[i!].data.updateValue(Set<String>(), forKey: "keywords")
            keywords = data[i!].data["keywords"] as! Set<String>
        }
        keywords!.removeAll()
        keys.forEach { (str) in
            keywords!.insert(str)
        }
    }
}
