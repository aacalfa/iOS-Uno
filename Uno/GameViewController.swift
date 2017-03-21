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
import Foundation

class GameViewController: UIViewController {
    // State machine variables
    var menuState = Menu()
    var gamePlayState = GamePlay()
    var endGameState = EndGame()
    var stateMachine: GKStateMachine?
    
    var cardDeck: Stack<Card?> = Stack<Card?>() // Game's card deck
    var discardPile: Stack<Card?> = Stack<Card?>() // Accumulates cards played
	
    var playersVec: [Player?] = [] // Array that contains all players in the game
	var numOfPlayers: Int = 0 // Determines how many players are participating in the game
	
	var playerOrderOfPlay: [Player?] = [] // Array that determines the order of play
	var currPlayerIdx: Int = 0 // Index of the player who is currently playing
	var isOrderClockwise: Bool = true // Determines direction of play
	
    var menuScene: MenuScene? // Stores MenuScene object
    var gameScene: GameScene? // Stores GameScene object
    var currentCard: Card? = nil // Current card on the table
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

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
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = false // Draw background first, then cards
        menuScene?.scaleMode = .resizeFill
        skView.presentScene(menuScene)
        
        // Add observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePlayerCardTouch), name: Notification.Name("handlePlayerCardTouch"), object: nil)
    }
    
    
    /// Create state machine
    func createStateSm() {
        stateMachine = GKStateMachine(states: [menuState, gamePlayState, endGameState])
    }
    
    
    /// Initialize array of players
    func initPlayers() {
        playersVec = [Player?](repeating: nil, count: numOfPlayers)
        let initNumOfCards : Int = 7
        for i in 0..<numOfPlayers {
            var cards = [Card?](repeating: nil, count: initNumOfCards)
            for j in 0..<initNumOfCards {
                cards[j] = cardDeck.pop()
            }
            
            playersVec[i] = Player(cards: cards, name: "Player" + String(i), flagAI: i != 0)
        }
		
		// Now that we have the players created, let's set an order of play
		setOrderOfPlay()
        // Now it's time to create the discard pile
        initDiscardPile()
    }
	
    
	/// Set order of play
	func setOrderOfPlay() {
		assert(!playersVec.isEmpty)
		// Considering the default order to be clockwise and starting from top of screen,
		// If there are 4 players in total, the order is player 1 - player 3 - player 0 - player 2
		// If there are 3 players in total, the order is player 1 - player 0 - player 2
		// If there are 2 players in total, the order is player 1 - player 0
		switch numOfPlayers {
		case 4:
			playerOrderOfPlay.append(playersVec[1])
			playerOrderOfPlay.append(playersVec[3])
			playerOrderOfPlay.append(playersVec[0])
			playerOrderOfPlay.append(playersVec[2])
			break
		case 3:
			playerOrderOfPlay.append(playersVec[1])
			playerOrderOfPlay.append(playersVec[0])
			playerOrderOfPlay.append(playersVec[2])
			break
		case 2:
			playerOrderOfPlay.append(playersVec[1])
			playerOrderOfPlay.append(playersVec[0])
			break
		default:
			assert(false) // should never happen!
		}
		// To make things more interesting, let's pick a random player to start first:
		let lower : UInt32 = 0
		let upper : UInt32 = UInt32(numOfPlayers - 1)
		currPlayerIdx = Int(arc4random_uniform(upper - lower) + lower)
        currPlayerIdx = numOfPlayers <= 3 ? 1 : 2 // Uncomment this to test first play by non-AI player
	}
	
    
    /// Initialize discard pile
    func initDiscardPile() {
        // After handing cards to the players, set first card for discard pile
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
    
    func handleAIPlayersPlay() {
        let player = playerOrderOfPlay[currPlayerIdx]
        if (player?.isAI())! {
            // Sleep for 3 seconds
            sleep(3)
            
            // Play
            let card = playAIStrategySimpleV1(player: player!)
            
            if card != nil {
                // Update model and view
                gameScene?.moveCardFromHandToDiscardPile(player: player!, card: card!)
                
                // Update order of play
                currPlayerIdx = isOrderClockwise ? currPlayerIdx + 1 : currPlayerIdx - 1
                if currPlayerIdx >= numOfPlayers {
                    currPlayerIdx = 0
                }
                gameScene?.drawCurrentPlayerLabel()
            } else {
                // TODO: Handle nil card (needs to draw a card)
            }
        }
    }
    
    
    /// Event handler of the card chosen by the non-AI player
    ///
    /// - Parameter notification: The card touched by the non-AI player
    func handlePlayerCardTouch(notification: Notification) {
        // TODO: Fully handle the event
        if let playerCardDict = notification.object as? [String: AnyObject] {
            let player = playerCardDict["player"] as! Player
            let card = playerCardDict["card"] as! Card
            if isPlayValid(player: player, card: card) {
                // Add animation to card moving from hand to discard pile
                // After completing the animation, doFinishHandlePlayerCardTouch will be called
                gameScene?.moveCardFromHandToDiscardPile(player: player, card: card)
                
                // Update order of play
                currPlayerIdx = isOrderClockwise ? currPlayerIdx + 1 : currPlayerIdx - 1
                if currPlayerIdx >= numOfPlayers {
                    currPlayerIdx = 0
                }
                gameScene?.drawCurrentPlayerLabel()
            } else {
                gameScene?.invalidPlayLabel.isHidden = false
            }
        }
    }
    
    
    /// Finish handlePlayerCardTouch by updating view and model
    ///
    /// - Parameters:
    ///   - player: player that's currently playing
    ///   - card: card that will be played
    func doFinishHandlePlayerCardTouch(player: Player, card: Card) {
        // Update model
        player.playCard(card: card)

        // Update discard pile
        updateDiscardPile(card: card)

        // Update view
        gameScene?.invalidPlayLabel.isHidden = true
        gameScene?.drawTopDiscardPileCard()
        // Rearrange cards: as cards move from hand to discard pile, update cards from
        // player hand so that they are shown right next to each other. cardPosIdx corresponds
        // is to tell drawPlayerCards which players card we are adjusting in the position
        // perspective.
        gameScene?.drawPlayerCards(player: player, cardPosIdx: playersVec.index{$0 === player}!)
        
        handleAIPlayersPlay()
    }
    
    /// Check if card attempted to be played is valid.
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
                if (self.currentCard?.cardColor != card.cardColor && self.currentCard?.cardValue != card.cardValue) {
                    return false
                }
            }
        }
        
        return true
    }
    
    /// Simple strategy for AI player (version 1).
    ///
    /// Main objective: prioritize playing cards with higher values.
    /// Does use any game feedback information.
    
    /// List of actions in descending order of priority (if card to-be-played is available and valid):
    /// 0. Play either Wild Draw Four or Wild card
    ///   0.1 Play Wild Draw Four card
    ///   0.2 Play Wild card
    /// 1. Play card matching color, type (except Wild and Wild Draw Four), or value that has the highest value
    ///
    /// - Parameters:
    ///   - player: current AI player that must choose card to play
    /// - Returns: card to be played
    func playAIStrategySimpleV1(player: Player) -> Card? {
        // TODO: Needs testing
        
        var playedCard: Card? = nil
        
        // Action 0.
        if player.hasCard(card: CardUtils.wildDrawFourCard) && self.isPlayValid(player: player, card: CardUtils.wildDrawFourCard) {
            playedCard = CardUtils.wildDrawFourCard
        } else if player.hasCard(card: CardUtils.wildCard) && self.isPlayValid(player: player, card: CardUtils.wildCard) {
            playedCard = CardUtils.wildCard
        } else {
            // Action 1.
            playedCard = player.getMaximumValueCard() // Exclude Wild Draw Four card (default parameter)
            
            // If there is a match in card value, no need to check colors
            if playedCard != nil && playedCard?.cardValue != currentCard?.cardValue {
                if currentCard?.cardColor == CardColor.blue {
                    // Get blue card with maximum value
                    let maxBlueCard = player.getMaximumValueCard(cardColor: CardColor.blue)
                    if maxBlueCard != nil {
                        if playedCard != nil && (playedCard?.cardValue)! < (maxBlueCard?.cardValue)! {
                            playedCard = maxBlueCard
                        }
                    }
                } else if currentCard?.cardColor == CardColor.green {
                    // Get green card with maximum value
                    let maxGreenCard = player.getMaximumValueCard(cardColor: CardColor.green)
                    if maxGreenCard != nil {
                        if playedCard != nil && (playedCard?.cardValue)! < (maxGreenCard?.cardValue)! {
                            playedCard = maxGreenCard
                        }
                    }
                } else if currentCard?.cardColor == CardColor.red {
                    // Get red card with maximum value
                    let maxRedCard = player.getMaximumValueCard(cardColor: CardColor.red)
                    if maxRedCard != nil {
                        if playedCard != nil && (playedCard?.cardValue)! < (maxRedCard?.cardValue)! {
                            playedCard = maxRedCard
                        }
                    }
                } else {
                    // Get yellow card with maximum value
                    let maxYellowCard = player.getMaximumValueCard(cardColor: CardColor.yellow)
                    if maxYellowCard != nil {
                        if playedCard != nil && (playedCard?.cardValue)! < (maxYellowCard?.cardValue)! {
                            playedCard = maxYellowCard
                        }
                    }
                }
            } else {
                playedCard = nil
            }
        }
        
        return playedCard
    }
}
