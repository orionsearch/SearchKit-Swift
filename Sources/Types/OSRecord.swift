//
//  OSRecord.swift
//  SearchKit-Swift
//
//  Created by Arthur Guiot on 5/3/19.
//  Copyright © 2019 Arthur Guiot. All rights reserved.
//

import Foundation

/// `OSRecord` is an object representing a row in your database. It can be modified to keep certain properties or hide data. It's a pretty light object that helps OrionSearch unifying its ecosystem architecture without using native objects for better integration across all the different platforms.
///
/// The `OSRecord` object will mostly be used as a read-only property given by the `perform` method in `OrionSearch`. But it can also be created manually for in-memory databases:
/// ```swift
/// let record = OSRecord(data: [ ... ]) // creates the record
/// ```
///
/// ## Accessing the data
///
/// `OSRecord` has a simple `data` property to access the data originally given.
/// ```swift
/// record.data["myproperty"]
/// ```
public class OSRecord {
    
    /// record's data
    public var data: [String: Any]
    /// Record's score. Used for sorting.
    public var score: Double = 0
    
    /// The initializer manages the record's data
    ///
    /// - Parameter data: Takes a dictionnary as input, represent the record's data
    public init(data: [String: Any]) {
        self.data = data
    }
    
    /// Record's main value
    public var main: String?
    /// Set record's main property
    ///
    /// - Parameter key: The key that will act as main key
    public func main(key: String) {
        if data[key] != nil {
            self.main = key
        }
    }
    
    /// Record's secondary value
    public var secondary: String?
    /// Set record's main property
    ///
    /// - Parameter key: The key that will act as secondary key
    public func secondary(key: String) {
        if data[key] != nil {
            self.secondary = key
        }
    }
    
    /// Keys of the data object
    public var keys: [String] {
        return Array<String>(self.data.keys)
    }
    /// Values of the data object
    public var values: [Any] {
        return Array<Any>(self.data.values)
    }
}
