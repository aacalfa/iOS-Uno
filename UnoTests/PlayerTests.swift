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
    
    func testInitialPoints() {
        player1 = Player(cards: [redCard0, redCard1, blueCard2])
        
        XCTAssert(player1.getPoints() == 0)
    }
    
    func testGetSetPoints() {
        player1 = Player(cards: [redCard0, redCard1, blueCard2])
        
        let points: Int = 100
        player1.setPoints(points: points)
        
        XCTAssert(player1.getPoints() == points)
    }
    
    func testResetPoints() {
        player1 = Player(cards: [redCard0, redCard1, blueCard2])
        
        let points: Int = 100
        player1.setPoints(points: points)
        player1.resetPoints()
        
        XCTAssert(player1.getPoints() == 0)
    }
    
    func testInitialName() {
        player1 = Player(cards: [redCard0, redCard1, blueCard2])
        
        XCTAssert(player1.getName() == "Anonymous")
    }
    
    func testGetSetName() {
        player1 = Player(cards: [redCard0, redCard1, blueCard2])
        
        let name: String = "Player1"
        player1.setName(name: name)
        
        XCTAssert(player1.getName() == name)
    }
    
    func comparePlayers(player1: Player, player2: Player) -> Bool {
        var success: Bool = true
        for card in player1.getCards() {
            if !player2.getCards().contains(where: {$0 == card}) {
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
    
    func testPlayerAI() {
        player1 = Player(cards: [redCard0, redCard1])
        
        XCTAssert(!player1.isAI())
    }
    
    func testHasCardType() {
        player1 = Player(cards: [redCard0, redCard1])
        
        XCTAssertTrue(player1.hasCardType(cardType: redCard0.cardType))
    }
    
    func testHasCardColor() {
        player1 = Player(cards: [redCard0, redCard1])
        
        XCTAssertTrue(player1.hasCardColor(cardColor: redCard0.cardColor))
    }
    
    func testHasCardValue() {
        player1 = Player(cards: [redCard0, redCard1])
        
        XCTAssertTrue(player1.hasCardValue(cardValue: redCard0.cardValue))
    }
    
    func testHasCard() {
        player1 = Player(cards: [redCard0, redCard1])
        
        XCTAssertTrue(player1.hasCard(card: redCard0))
    }
    
    func testHasCardObject() {
        player1 = Player(cards: [redCard0, redCard1])
        
        XCTAssertTrue(player1.hasCardObject(card: redCard0))
    }
    
    func testHasCardObjectFalse() {
        player1 = Player(cards: [redCard0, redCard1])
        let redCard0Other = Card(cardColor: CardColor.red, cardValue: 0)
        
        XCTAssertFalse(player1.hasCardObject(card: redCard0Other))
    }
    
    func testHasCardTypeFalse() {
        player1 = Player(cards: [redCard0, redCard1])
        
        XCTAssertFalse(player1.hasCardType(cardType: CardUtils.wildCard.cardType))
    }
    
    func testHasCardColorFalse() {
        player1 = Player(cards: [redCard0, redCard1])
        
        XCTAssertFalse(player1.hasCardColor(cardColor: blueCard2.cardColor))
    }
    
    func testHasCardValueFalse() {
        player1 = Player(cards: [redCard0, redCard1])
        
        XCTAssertFalse(player1.hasCardValue(cardValue: blueCard2.cardValue))
    }
    
    func testHasCardFalse() {
        player1 = Player(cards: [redCard0, redCard1])
        
        XCTAssertFalse(player1.hasCard(card: blueCard2))
    }
    
    func testGetCard() {
        player1 = Player(cards: [redCard0, redCard1, CardUtils.wildDrawFourCard])
        
        XCTAssert(player1.getCard(card: redCard1) === redCard1)
    }
    
    func testGetCard2() {
        player1 = Player(cards: [redCard0, redCard1, CardUtils.wildDrawFourCard])
        let redCard0Other = Card(cardColor: CardColor.red, cardValue: 0)
        
        XCTAssert(player1.getCard(card: redCard0Other) === redCard0)
    }
    
    func testGetCardFalse() {
        player1 = Player(cards: [redCard0, redCard1, CardUtils.wildDrawFourCard])
        let wildDrawFourCardOther = Card(cardColor: CardColor.other, cardValue: SpecialVals.wildDrawFour.rawValue)
        
        XCTAssert(player1.getCard(card: wildDrawFourCardOther) !== wildDrawFourCardOther)
    }
    
    func testGetMaximumValueCard() {
        player1 = Player(cards: [redCard0, redCard1, CardUtils.wildDrawFourCard])
        
        XCTAssert(player1.getMaximumValueCard() == redCard1)
    }
    
    func testGetMaximumValueCard2() {
        player1 = Player(cards: [redCard0, redCard1, CardUtils.wildDrawFourCard])
        
        XCTAssert(player1.getMaximumValueCard(excludeWildDrawFourCard: false) == CardUtils.wildDrawFourCard)
    }
    
    func testGetMaximumValueCardFalse() {
        player1 = Player(cards: [redCard0, redCard1, CardUtils.wildDrawFourCard])
        
        XCTAssert(player1.getMaximumValueCard(excludeWildDrawFourCard: false) != redCard1)
    }
    
    func testGetMaximumValueCardColor() {
        player1 = Player(cards: [redCard0, redCard1, blueCard2])
        
        XCTAssert(player1.getMaximumValueCard(cardColor: CardColor.red) == redCard1)
    }
    
    func testGetMaximumValueCardColorFalse() {
        player1 = Player(cards: [redCard0, redCard1, blueCard2])
        
        XCTAssert(player1.getMaximumValueCard(cardColor: CardColor.red) != redCard0)
    }
    
    func testGetMaximumValueCardColorFalse2() {
        player1 = Player(cards: [redCard0, redCard1, blueCard2])
        
        XCTAssert(player1.getMaximumValueCard(cardColor: CardColor.red) != blueCard2)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
