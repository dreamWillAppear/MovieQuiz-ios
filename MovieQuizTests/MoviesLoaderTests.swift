import XCTest

@testable import MovieQuiz

class MoviesLoaderTest : XCTestCase {
    
    func testSuccessLoading() throws {
        let loader = MoviesLoader()
        
        let exception = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            switch result {
            case .success(let movies):
                
                exception.fulfill()
            case .failure(_):
                
                XCTFail("Unexpected failure")
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    
    func testFailureLoading() throws {
        
    }
}

