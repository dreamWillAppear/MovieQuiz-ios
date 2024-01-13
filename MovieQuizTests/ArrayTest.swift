import XCTest
@testable import MovieQuiz

class ArrayTest: XCTestCase {
    func testGetValueInRange() throws {
        let array = [1, 1, 2, 4, 5, 6, 7]
        
        let value = array[safe: 4]
        
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 5)
    }
    
    func testGetValueOutOfRange() throws {
        let array = [1, 1, 2, 4, 5, 6, 7]
        
        let value = array[safe: 20]
        
        XCTAssertNil(value)
    }
}

