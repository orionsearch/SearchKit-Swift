//
//  SearchKit_SwiftTests.swift
//  SearchKit-SwiftTests
//
//  Created by Arthur Guiot on 5/3/19.
//  Copyright © 2019 Arthur Guiot. All rights reserved.
//

import XCTest
@testable import SearchKit_Swift

class SearchKit_SwiftTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testOSRecord() {
        let record = OSRecord(data: [
            "title": "Hello World",
            "author": "Arthur Guiot",
            "type": "book"
            ])
        XCTAssert(record.keys.contains("title") && record.keys.count == 3)
        
        record.main(key: "title")
        XCTAssert(record.main == "title")
    }
    func testOSQuery() {
        let query = OSQuery(str: "Hello World author:someone")
        XCTAssert(query.parsed["filters"] as! [[String]] == [["author", "someone"]])
        XCTAssert(query.parsed["keywords"] as! [String : Double] == [
            "hello": 0.5,
            "world": 0.5
        ])
    }
    func testOSDatabase() {
        let db = OSDatabase()
        db.data = [
            OSRecord(data: [
                "title": "Hello World",
                "author": "Me"
            ]),
            OSRecord(data: [
                "title": "How are you",
                "author": "you"
            ]),
            OSRecord(data: [
                "title": "Random titles",
                "author": "someone"
            ]),
            OSRecord(data: [
                "title": "Just for test",
                "author": "someone else"
            ])
        ]
        db.configure(main: "title")
        XCTAssert(db.keywordsCache.contains("random"))
        
        db.add(records: [
            OSRecord(data: [
                "title": "OrionSearch is awesome",
                "author": "github"
            ])
        ], main: "title")
        
        XCTAssert(db.keywordsCache.contains("orionsearch"))
    }
}
