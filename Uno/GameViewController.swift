//
//  GameViewController.swift
//  Uno
//
//  Created by Andre Calfa on 3/4/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    // State machine variables
    var menuState = Menu()
    var gamePlayState = GamePlay()
    var endGameState = EndGame()
    var stateMachine: GKStateMachine?
    
    var cardDeck: Stack<Card?> = Stack<Card?>() // Game's card deck
    var discardPile: Stack<Card?> = Stack<Card?>() // accumulates cards played
    var playersVec: [Player?] = [] // Array that contains all players in the game
    var numOfPlayers: Int = 0 // Determines how many players are participating in the game
    var menuScene: MenuScene? // Stores MenuScene object
    var currentCard: Card? = nil // Current card on the table

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load card deck
        CardUtils.loadDeck()
        
        // Shuffle card deck
        CardUtils.shuffleDeck()
        
        // Populate stack of cards
        for card in CardUtils.getCardDeck() {
            cardDeck.push(card)
        }
        
        // Create state machines
        createStateSm()
        
        // Present main menu
        menuScene = MenuScene(size: view.bounds.size)
        menuScene?.viewController = self
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = false // Draw background first, then cards
        menuScene?.scaleMode = .resizeFill
        skView.presentScene(menuScene)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func createStateSm() {
        stateMachine = GKStateMachine(states: [menuState, gamePlayState, endGameState])
    }
    
    func initPlayers() {
        playersVec = [Player?](repeating: nil, count: numOfPlayers)
        let initNumOfCards : Int = 7
        for i in 0..<numOfPlayers {
            var cards = [Card?](repeating: nil, count: initNumOfCards)
            for i in 0..<initNumOfCards {
                cards[i] = cardDeck.pop()
            }
            
            playersVec[i] = Player(cards: cards, name: "Player" + String(i), flagAI: i == 0)
        }
        
        // Now it's time to create the discard pile
        initDiscardPile()
    }
    
    func initDiscardPile() { // After handing cards to the players, set first card for discard pile
        assert(!cardDeck.isEmpty())
        updateDiscardPile(card: cardDeck.pop()!)
    }
    
    /// Add card to top of discard pile
    ///
    /// - Parameter card: card to be inserted
    func updateDiscardPile(card: Card) {
        currentCard = card
        discardPile.push(card)
    }
    
    /// Checks if card attempted to be played is valid.
    ///
    /// - Parameters:
    ///   - player: Player attempting to play a card
    ///   - card: Potential card to be played
    /// - Returns: True if card is valid, false otherwise
    func isPlayValid(player: Player, card: Card) -> Bool {
        // TODO: Needs testing
        
        // Wild card can always be played
        if card.cardType != CardType.wild {
            // Check if Wild Draw Four card
            if card.cardValue == SpecialVals.wildDrawFour.rawValue {
                // Check card color condition
                if player.hasCardColor(cardColor: self.currentCard!.cardColor) {
                    return false
                }
            } else {
                // Check card color, type, and value
                if (self.currentCard?.cardColor != card.cardColor && self.currentCard?.cardType != card.cardType && self.currentCard?.cardValue != card.cardValue) {
                    return false
                }
            }
        }
        
        return true
    }
    
    /// Simple strategy for AI player (version 1).
    ///
    /// Main objective: prioritize playing cards with higher values.
    /// Only uses the number of cards of the next player as game feedback information.
    
    /// List of actions in descending order of priority (if card to-be-played is available and valid):
    /// 0. Play either Wild Draw Four or Wild card
    ///   0.1 Play Wild Draw Four card
    ///   0.2 Play Wild card
    /// 1. Play card matching color, type (except Wild and Wild Draw Four), or value that has the highest value
    ///
    /// - Parameters:
    ///   - playerAI: current AI player that must choose card to play
    ///   - nextPlayer: player that will play after playerAI
    /// - Returns: card to be played
    func playAIStrategySimpleV1(playerAI: Player, nextPlayer: Player) -> Card? {
        // TODO: Needs testing
        
        var playedCard: Card? = nil
        
        // Action 0.
        if playerAI.hasCard(card: CardUtils.wildDrawFourCard) && self.isPlayValid(player: playerAI, card: CardUtils.wildDrawFourCard) {
            playedCard = CardUtils.wildDrawFourCard
        } else if playerAI.hasCard(card: CardUtils.wildCard) && self.isPlayValid(player: playerAI, card: CardUtils.wildCard) {
            playedCard = CardUtils.wildCard
        } else {
            // Action 1.
            playedCard = playerAI.getMaximumValueCard()
            
            // If there is a match in card value, no need to check colors
            if playedCard != nil && playedCard?.cardValue != currentCard?.cardValue {
                if currentCard?.cardColor == CardColor.blue {
                    // Check if blue card has maximum value
                    let maxBlueCard = playerAI.getMaximumValueCard(cardColor: CardColor.blue)
                    if maxBlueCard != nil {
                        if playedCard != nil && (playedCard?.cardValue)! < (maxBlueCard?.cardValue)! {
                            playedCard = maxBlueCard
                        }
                    }
                } else if currentCard?.cardColor == CardColor.green {
                    // Check if green card has maximum value
                    let maxGreenCard = playerAI.getMaximumValueCard(cardColor: CardColor.green)
                    if maxGreenCard != nil {
                        if playedCard != nil && (playedCard?.cardValue)! < (maxGreenCard?.cardValue)! {
                            playedCard = maxGreenCard
                        }
                    }
                } else if currentCard?.cardColor == CardColor.red {
                    // Check if red card has maximum value
                    let maxRedCard = playerAI.getMaximumValueCard(cardColor: CardColor.red)
                    if maxRedCard != nil {
                        if playedCard != nil && (playedCard?.cardValue)! < (maxRedCard?.cardValue)! {
                            playedCard = maxRedCard
                        }
                    }
                } else {
                    // Check if yellow card has maximum value
                    let maxYellowCard = playerAI.getMaximumValueCard(cardColor: CardColor.yellow)
                    if maxYellowCard != nil {
                        if playedCard != nil && (playedCard?.cardValue)! < (maxYellowCard?.cardValue)! {
                            playedCard = maxYellowCard
                        }
                    }
                }
            }
        }
        
        // Update model
        if playedCard != nil {
            playerAI.playCard(card: playedCard!)
        } else {
            playerAI.drawCard(card: cardDeck.pop()!)
        }
        
        return playedCard
    }
}
