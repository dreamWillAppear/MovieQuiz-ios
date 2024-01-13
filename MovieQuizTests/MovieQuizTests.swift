
import XCTest

struct ArithmeticOperations {
    func addition(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 + num2)
        }
    }
    
    func subtraction(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 - num2)
        }
    }
    
    func multiplication(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 * num2)
        }
    }
}

final class MovieQuizTests: XCTestCase {
    
    func testAdditon() throws {
        let arithmeticOperation = ArithmeticOperations()
        
        let exception = expectation(description: "Waitng for additon") //функция для ожидания
        
        arithmeticOperation.addition(num1: 1 , num2: 2) { result in
            XCTAssertEqual(result, 3)
            exception.fulfill() //сигнал об окончании ожидания т.к. функция выполнена
        }
        
        waitForExpectations(timeout: 2) //сигнал о том, что надо бы оподождать 2 сек 
    }
    
}
