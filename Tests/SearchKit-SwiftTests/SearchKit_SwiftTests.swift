import XCTest
@testable import SearchKit_Swift

final class SearchKit_SwiftTests: XCTestCase {
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
        let query = OSQuery("Hello World author:someone")
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
    func testOSQuick() {
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
        
        let os = OrionSearch(db: db)
        
        let query = OSQuery("random test", lang: "en", keys: ["title", "author"])
        
        var out = [String]()
        self.measure {
            out = [] // empty out, as the code runs multiple time
            os.perform(query: query, type: .quick) { (record) in
                out.append(record.data["title"] as! String)
            }
        }
        
        XCTAssert(out.contains("Just for test") && out.contains("Random titles"))
    }
    func testOSNormal() {
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
                "title": "Hello World",
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
        
        let os = OrionSearch(db: db, filters: ["author"])
        
        let query = OSQuery("World author:me", lang: "en", keys: ["title", "author"])
        
        var out = [[String: String]]()
        self.measure {
            out = [] // empty out, as the code runs multiple time
            os.perform(query: query, type: .normal) { (record) in
                out.append([
                    "title": record.data["title"] as! String,
                    "author": record.data["author"] as! String
                ])
            }
        }
        XCTAssertEqual(out.count, 1)
        print(out)
        XCTAssertEqual(out[0]["title"], "Hello World")
        XCTAssertEqual(out[0]["author"], "Me")
    }

    static var allTests = [
        ("OS Records", testOSRecord),
        ("OS Query", testOSQuery),
        ("OS Database", testOSDatabase),
        ("OS Quick", testOSQuick),
        ("OS Normal", testOSNormal)
    ]
}
