import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SearchKit_SwiftTests.allTests),
    ]
}
#endif
