//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Богдан Шестаков on 14.01.2024.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        sleep(1)
        let firstPoster = app.images["Poster"].screenshot().pngRepresentation
        app.buttons["Yes"].tap()
        sleep(1)
        let secondPoster = app.images["Poster"].screenshot().pngRepresentation
        XCTAssertNotEqual(firstPoster, secondPoster)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(1)
        let firstPoster = app.images["Poster"].screenshot().pngRepresentation
        app.buttons["No"].tap()
        sleep(1)
        let secondPoster = app.images["Poster"].screenshot().pngRepresentation
        XCTAssertNotEqual(firstPoster, secondPoster)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testGameFinish() {
        sleep(1)
        
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(1)
        }
        
        let alert = app.alerts["AlertGameResult"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }
    
    func testAlertDismiss() {
        sleep(1)
        
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(1)
        }
        
        let alert = app.alerts["AlertGameResult"]
        alert.buttons.firstMatch.tap()
        sleep(1)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}

