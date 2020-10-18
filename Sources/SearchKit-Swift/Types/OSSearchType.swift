//
//  OSSearchType.swift
//  SearchKit-Swift
//
//  Created by Arthur Guiot on 8/3/19.
//  Copyright © 2019 Arthur Guiot. All rights reserved.
//

import Foundation

/// The type of your search.
///
/// It can be:
/// - `.quick`: for `OSQuick` searches,
/// - `.normal`: for `OSNormal` searches,
/// - `.advanced`: for `OSAdvanced` searches powered by machine learning
public enum OSSearchType {
    /// for `OSQuick` searches
    case quick
    /// for `OSNormal` searches
    case normal
    /// for `OSAdvanced` searches powered by machine learning
    case advanced
}
