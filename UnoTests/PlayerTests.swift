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
    }
    
    override func tearDown() {
        super.tearDown()
        
        player1 = nil
        player2 = nil
    }
    
    func comparePlayers(player1: Player, player2: Player) -> Bool {
        var success: Bool = true
        for card in player1.cards {
            if !player2.cards.contains(where: {$0 == card}) {
                success = false
            }
        }
        return success
    }
    
    func testPlayCardExists() {
        player1 = Player(cards: [redCard0, redCard1, blueCard2])
        
        player2 = Player(cards: [redCard0, redCard1])
        player1.playCard(card: blueCard2)
        
        XCTAssertTrue(comparePlayers(player1: player1, player2: player2))
    }
    
    func testPlayCardDoesNotExist() {
        player1 = Player(cards: [redCard0, redCard1])
        player2 = player1.copy()
        
        player1.playCard(card: blueCard2)
        
        XCTAssertTrue(comparePlayers(player1: player1, player2: player2))
    }
    
    func testDrawCardExists() {
        player1 = Player(cards: [redCard0, redCard1, blueCard2])
        player2 = player1.copy()
        
        player2.drawCard(card: blueCard2)
        
        XCTAssertTrue(comparePlayers(player1: player1, player2: player2))
    }
    
    func testDrawCardDoesNotExist() {
        player1 = Player(cards: [redCard0, redCard1])
        player2 = player1.copy()
        
        player2.drawCard(card: blueCard2)
        
        XCTAssertTrue(comparePlayers(player1: player1, player2: player2))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
