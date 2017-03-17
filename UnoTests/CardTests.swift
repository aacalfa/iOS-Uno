//
//  CardTests.swift
//  Uno
//
//  Created by Andre Calfa on 3/17/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import XCTest
@testable import Uno

class CardTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInvalidColor() {
        // Wild card should not have a color
        XCTAssertThrowsError(try Card.isValidCard(cardColor: CardColor.blue, cardValue: SpecialVals.wildDrawFour.rawValue) ) {
            (error) -> Void in XCTAssertEqual(error as? CardPropertyError, CardPropertyError.invalidColor)
        }

        XCTAssertThrowsError(try Card.isValidCard(cardColor: CardColor.green, cardValue: SpecialVals.wild.rawValue) ) {
            (error) -> Void in XCTAssertEqual(error as? CardPropertyError, CardPropertyError.invalidColor)
        }
        // Non wild card should have a color
        XCTAssertThrowsError(try Card.isValidCard(cardColor: CardColor.other, cardValue: SpecialVals.drawTwo.rawValue) ) {
            (error) -> Void in XCTAssertEqual(error as? CardPropertyError, CardPropertyError.invalidColor)
        }
    }
    
    func testInvalidValue() {
        // Values must be between 0 and SpecialVals.wildDrawFour.rawValue
        XCTAssertThrowsError(try Card.isValidCard(cardColor: CardColor.green, cardValue: -1) ) {
            (error) -> Void in XCTAssertEqual(error as? CardPropertyError, CardPropertyError.invalidValue)
        }
        XCTAssertThrowsError(try Card.isValidCard(cardColor: CardColor.green, cardValue: 20) ) {
            (error) -> Void in XCTAssertEqual(error as? CardPropertyError, CardPropertyError.invalidValue)
        }

        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
