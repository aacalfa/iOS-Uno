//
//  PlayerTests.swift
//  Uno
//
//  Created by Bruno Abreu Calfa on 3/8/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import XCTest
@testable import Uno

class PlayerTests: XCTestCase {
    
    var player1, player2: Player!
    let redCard0 = Card(cardColor: CardColor.red, cardValue: 0)
    let redCard1 = Card(cardColor: CardColor.red, cardValue: 1)
    let blueCard2 = Card(cardColor: CardColor.blue, cardValue: 2)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let cards = [redCard0, redCard1, blueCard2]
        
        player1 = Player(cards: cards)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        player1 = nil
        player2 = nil
    }
    
    func testPlayCard() {
        player2 = Player(cards: [redCard0, redCard1])
        player1.playCard(card: blueCard2)
        
        XCTAssert(player1.toString() == player2.toString())
    }
    
    func testDrawCard() {
        player2 = Player(cards: [redCard0, redCard1])
        player2.drawCard(card: blueCard2)
        
        XCTAssert(player1.toString() == player2.toString())
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
