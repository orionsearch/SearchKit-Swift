//
//  OrionSearch.swift
//  SearchKit-Swift
//
//  Created by Arthur Guiot on 8/3/19.
//  Copyright © 2019 Arthur Guiot. All rights reserved.
//

import Foundation

/// `OrionSearch` is the main object of this framework. It will coordinate and operates all the operations and queries inside your database. This is how you construct it:
/// ```swift
/// let db = OSDatabase()
/// /* ... */
/// let os = OrionSearch(db: db, filters: ["author", "type"])
/// ```
///
/// > **Filters**
/// >
/// > Filters are a way of filtering the data. It's very similar to GitHub's search filters like `is:issue` or `language:javascript` that acts as conditions.
///
/// ## Performing queries
/// Queries are an important part of the research experience. That's why querying the database is extremely simple:
/// ```swift
/// let db = OSDatabase()
/// /* ... */
/// let os = OrionSearch(db: db, filters: ["author", "type"])
///
/// let query = OSQuery("Rose are red type:poem") // "Rose are red" + filter looks for a poem
///
/// let type: OSSearchType = .normal // Will perform normal search
///
/// os.perform(query: query, type: type) { (record) in
///    // Will call this function for every records
/// }
/// ```
public class OrionSearch {
    var db: OSDatabase
    var filters: [String]
    
    /// OrionSearch's initializer
    ///
    /// - Parameters:
    ///   - db: Your database
    ///   - filters: Your filters
    public init(db: OSDatabase, filters: [String] = []) {
        self.db = db
        self.filters = filters
    }
    
    /// Add filters
    ///
    /// - Parameter filters: Your filters
    public func add(filters: [String]) {
        self.filters.append(contentsOf: filters)
    }
    
    /// `perform` will be the function you want to call to basically search something in your database.
    ///
    /// The `perform` function is synchronous and blocking. While you can see here a weakness, it's actually a strength as **you** have the hand on optimisation and thread management.
    ///
    /// > **⚠️ We strongly recommend to dispatch the function**
    /// > You can do that by doing something like:
    /// ```swift
    /// DispatchQueue.global().sync {
    ///     os.perform(query: query, type: .normal) { ... }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - query: Your query as an `OSQuery`. Please see `OSQuery` for more information.
    ///   - type: The type of your search. It can be: `.quick`: for `OSQuick` searches, `.normal`: for `OSNormal` searches and `.advanced`: for `OSAdvanced` searches powered by machine learning
    ///   - completion: A callback that will be called each time a record is found. All records will be sorted.
    ///
    public func perform(query: OSQuery, type: OSSearchType = .normal, completion: (OSRecord) -> Void) {
        
    }
    
    /// Register end plugin
    ///
    /// - Parameter plugin: The desired plugin
    public func register(plugin: ([OSRecord]) -> [OSRecord]) {
        
    }
}
