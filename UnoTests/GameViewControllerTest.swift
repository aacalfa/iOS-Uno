//
//  GameViewControllerTest.swift
//  Uno
//
//  Created by Andre Calfa on 3/23/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import XCTest
import SpriteKit
import GameKit
@testable import Uno

class GameViewControllerTest: XCTestCase {
    
    var viewController: GameViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateInitialViewController() as! GameViewController
        viewController.viewDidLoad()
        viewController.numOfPlayers = 2
        viewController.initPlayers()
        loadCustomCardsForPlayer()
        let gameScene : GameScene = GameScene()
        gameScene.viewController = viewController
        viewController.gameScene = gameScene
        viewController.gameScene?.didMove(to: viewController.view as! SKView)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCheckValidPlay() {
        let player = viewController.playerOrderOfPlay[viewController.currPlayerIdx]
        let currentCard = viewController.currentCard
        for card in (player?.getCards())! {
            // Don't test wild cards here
            if card?.cardType == CardType.wild {
                continue
            }
            
            if card?.cardColor == currentCard?.cardColor {
                XCTAssertTrue(viewController.isPlayValid(player: player!, card: card))
            } else if card?.cardValue == currentCard?.cardValue {
                XCTAssertTrue(viewController.isPlayValid(player: player!, card: card))
            } else {
                XCTAssertFalse(viewController.isPlayValid(player: player!, card: card))
            }
        }
    }
    
    func testCheckPlaySkipCard() {
        // store who is the current player
        let oldCurrPlayer = viewController.currPlayerIdx
        
        let player = viewController.playerOrderOfPlay[viewController.currPlayerIdx]
        // Make sure we can play a skip card by forcing current card to be of same color
        viewController.currentCard = Card(cardColor: CardColor.red, cardValue: 1)
        let card = Card(cardColor: CardColor.red, cardValue: SpecialVals.skip.rawValue)
        // Simulate card being played
        viewController.doFinishHandlePlayerCardTouch(player: player!, card: card)
        // Check if current player is still player who used skip card
        let newCurrPlayer = viewController.currPlayerIdx
        XCTAssertTrue(oldCurrPlayer == newCurrPlayer)
    }
    
    
    /// To facilitate testing (and debugging) players will have a specific set of cards in their hands
    /// so we can simulate more easily each situation and corner cases. The hand will make sure we have
    /// cards from every color and all special cards
    func loadCustomCardsForPlayer() {
        let playerHuman = viewController.playersVec[0]
        var cards = [Card]()
        let colors = [CardColor.red,CardColor.green,CardColor.blue,CardColor.yellow]
        let specialVals = [SpecialVals.skip,SpecialVals.reverse,SpecialVals.drawTwo,SpecialVals.wild,
                           SpecialVals.wildDrawFour]
        for color in colors {
            // Use random number for value
            let lower : UInt32 = 0; let upper : UInt32 = 9
            let value = Int(arc4random_uniform(upper - lower) + lower)
            cards.append(Card(cardColor: color, cardValue: value))
        }

        for val in specialVals {
            if val.rawValue < SpecialVals.wild.rawValue {
                cards.append(Card(cardColor: CardColor.blue, cardValue: val.rawValue))
            } else {
                cards.append(Card(cardColor: CardColor.other, cardValue: val.rawValue))
            }
        }
        playerHuman?.setPlayerCards(cards: cards)
    }
}
