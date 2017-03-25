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
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleDrawCardDeckTouch), name: Notification.Name("handleDrawCardDeckTouch"), object: nil)
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
        
        // Deliberate design decision
        // Prevent action or wild cards to be on top of the discard pile at the beginning of a round
        var poppedCards: [Card?] = []
        var isActionOrWildCard: Bool = true
        while isActionOrWildCard {
            let peekCard = cardDeck.peek()
            if peekCard?.cardType == CardType.action || peekCard?.cardType == CardType.wild {
                poppedCards.append(cardDeck.pop())
            } else {
                isActionOrWildCard = false
            }
        }
        updateDiscardPile(card: cardDeck.pop()!)
        
        // Push back to deck action and wild cards that were popped, if any
        for card in poppedCards {
            cardDeck.push(card)
        }
    }
    
    /// Add card to top of discard pile
    ///
    /// - Parameter card: Card to be inserted
    func updateDiscardPile(card: Card) {
        currentCard = card
        discardPile.push(card)
    }
    
    /// Update draw card pile
    ///
    /// - Returns: Top card in the draw card pile
    func updateDrawPile() -> Card {
        assert(!cardDeck.isEmpty())
        return cardDeck.pop()!
    }
    
    
    /// Handle play by AI player
    func handleAIPlayersPlay() {
        let delayInSeconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            let player = self.playerOrderOfPlay[self.currPlayerIdx]
            if (player?.isAI())! {
                print("\n\(player!.getName())'s cards")
                print(player!.toString())
                
                // Play
                var mustDraw: Bool = false
                let card = self.playAIStrategySimpleV1(player: player!, mustDraw: &mustDraw)
                
                if card != nil {
                    // If card is wild, AI will have to choose a color for it
                    if card?.cardType == CardType.wild {
                        self.handleChoseColorForWildCard(player: player!, card: card!)
                    }
                    
                    // Update model and view
                    self.gameScene?.moveCardFromHandToDiscardPile(player: player!, card: card!)
                    self.gameScene?.drawCurrentPlayerLabel()
                    
                    print("Card played")
                    print(card!.toString())
                } else {
                    // TODO: Handle returned nil card
                    if mustDraw {
                        let drawnCard = self.cardDeck.peek()
                        if self.isPlayValid(player: player!, card: drawnCard) {
                            // If card is wild, AI will have to choose a color for it
                            if drawnCard?.cardType == CardType.wild {
                                self.handleChoseColorForWildCard(player: player!, card: drawnCard!)
                            }
                            // Add animation to card moving from draw pile to discard pile
                            // After completing the animation, doFinishHandleDrawDeckPile will be called
                            self.gameScene?.moveCardFromDrawToDiscardPile(player: player!, card: drawnCard!)
                        } else {
                            // Add animation to card moving from hand to discard pile
                            // After completing the animation, doFinishHandleDrawCardDeckTouch will be called
                            self.gameScene?.moveCardFromDrawToPlayerHand(player: player!, cardPosIdx: self.playersVec.index{$0 === player}!, card: drawnCard!)
                        }
                    }
                }
            } else {
                // TODO: Not working yet
//                if self.currentCard?.cardType == CardType.action || self.currentCard?.cardType == CardType.wild {
//                    self.handleCurrentActionOrWildCard(player: player!)
//                }
            }
        }
    }
    
    func handleCurrentActionOrWildCard(player: Player) {
/*
        // TODO: Not working yet
        
        // Index of the next player
        var nextPlayerInd = isOrderClockwise ? currPlayerIdx + 1 : currPlayerIdx - 1
        if nextPlayerInd >= numOfPlayers {
            nextPlayerInd = 0
        } else if nextPlayerInd < 0 {
            nextPlayerInd = numOfPlayers - 1
        }
        let nextPlayer = self.playerOrderOfPlay[nextPlayerInd]
        
        if self.currentCard?.cardValue == SpecialVals.drawTwo.rawValue {
            // TODO: Not working yet
//            // Next player in sequence draws two cards and misses a turn
//            self.gameScene?.drawTopDrawDeckCard()
//            gameScene?.moveCardFromDrawToPlayerHand(player: player, cardPosIdx: playersVec.index{$0 === nextPlayer}!, card: self.cardDeck.peek()!, updateOrder: false)
//            self.gameScene?.drawTopDrawDeckCard()
//            gameScene?.moveCardFromDrawToPlayerHand(player: player, cardPosIdx: playersVec.index{$0 === nextPlayer}!, card: self.cardDeck.peek()!, updateOrder: false)
//
//            // Update order of play
//            updateOrderOfPlay()
//            gameScene?.drawCurrentPlayerLabel()
        } else if self.currentCard?.cardValue == SpecialVals.reverse.rawValue {
            self.isOrderClockwise = !self.isOrderClockwise
        } else if self.currentCard?.cardValue == SpecialVals.skip.rawValue {
            self.currPlayerIdx = self.numOfPlayers > 2 ? nextPlayerInd : self.currPlayerIdx
            
            // Update order of play
            updateOrderOfPlay()
            gameScene?.drawCurrentPlayerLabel()
        } else if currentCard?.cardValue == SpecialVals.wild.rawValue {
            // TODO
            
            // Update order of play
            updateOrderOfPlay()
            gameScene?.drawCurrentPlayerLabel()
        } else if currentCard?.cardValue == SpecialVals.wildDrawFour.rawValue {
            // TODO
            
            // Update order of play
            updateOrderOfPlay()
            gameScene?.drawCurrentPlayerLabel()
        }
        
        // Go to the next player (possibly AI)
        handleAIPlayersPlay()
 */
    }
    
    /// Event handler of the card chosen by the non-AI player
    ///
    /// - Parameter notification: Dictionary containing the non-AI player and the touched card
    func handlePlayerCardTouch(notification: Notification) {
        if let playerCardDict = notification.object as? [String: AnyObject] {
            let player = playerCardDict["player"] as! Player
            let card = playerCardDict["card"] as! Card
            if isPlayValid(player: player, card: card) {
				// if card is wild, first ask human player what color he will choose
				if card.cardType == CardType.wild {
					gameScene?.drawColorPicker(player: player, card: card, fromCardDeck: false)
				} else {
					// Add animation to card moving from hand to discard pile
					// After completing the animation, doFinishHandlePlayerCardTouch will be called
					gameScene?.moveCardFromHandToDiscardPile(player: player, card: card)
				}
            } else {
                gameScene?.invalidPlayLabel.isHidden = false
            }
        }
    }
    
    
    /// Finish handlePlayerCardTouch by updating view and model. This is called when a card is played
    /// from hand to discard pile
    ///
    /// - Parameters:
    ///   - player: player that's currently playing
    ///   - card: card that will be played
    func doFinishHandlePlayerCardTouch(player: Player, card: Card) {
        // Update model
        player.playCard(card: card)

        // Update discard pile
        updateDiscardPile(card: card)
        
        // if the card played is skip or reverse, adjust who will play next and the view
//        let isSkip = handleSkipAndReverseCards(card: card)
        var isSkip: Bool = handleSkipAndReverseCards(card: card)
        
        // Check if draw two card
        if card.cardValue == SpecialVals.drawTwo.rawValue {
            // Skipe next player
            isSkip = true
            
            // Get next player
            let nextPlayer = getNextPlayer()
            assert(nextPlayer != nil)
            
            // Add two cards to the next player's hand
            // Add animation to card moving from draw pile to player's hand
            // After completing the animation, doFinishDrawTwoAction will be called
            gameScene?.moveCardFromDrawToPlayerHandDrawTwoAction(player: nextPlayer!, cardPosIdx: playersVec.index{$0 === nextPlayer}!, card1: updateDrawPile(), card2: cardDeck.peek()!)
        }

        // Update view
        // If the card played is wild, show in view what was the chosen color
        if card.cardType == CardType.wild {
            gameScene?.drawWildChosenColorLabel()
        } else {
            // make sure chosen color label is not displayed
            gameScene?.wildChosenColorLabel.isHidden = true
        }
        
        gameScene?.invalidPlayLabel.isHidden = true
        gameScene?.drawTopDiscardPileCard()
        // Rearrange cards: as cards move from hand to discard pile, update cards from
        // player hand so that they are shown right next to each other. cardPosIdx corresponds
        // is to tell drawPlayerCards which players card we are adjusting in the position
        // perspective.
        gameScene?.drawPlayerCards(player: player, cardPosIdx: playersVec.index{$0 === player}!)
        
        // Update order of play
        updateOrderOfPlay(withSkip: isSkip)
        gameScene?.drawCurrentPlayerLabel()
        
        // Go to the next player (possibly AI)
        handleAIPlayersPlay()
    }
    
    /// Event handler of the card chosen by the non-AI player
    ///
    /// - Parameter notification: Dictionary containing the non-AI player and the touched card
    func handleDrawCardDeckTouch(notification: Notification) {
        // TODO: Fully handle the event
        if let playerCardDict = notification.object as? [String: AnyObject] {
            let player = playerCardDict["player"] as! Player
            let card = playerCardDict["card"] as! Card
            let decidedToPlay = playerCardDict["decidedToPlay"] as! Bool
            
            print(player.getName() + " drew card " + card.toString())
            
            if !decidedToPlay {
                // Add animation to card moving from draw pile to player's hand
                // After completing the animation, doFinishHandleDrawCardDeckTouch will be called
                gameScene?.moveCardFromDrawToPlayerHand(player: player, cardPosIdx: playersVec.index{$0 === player}!, card: card)
			} else {
				gameScene?.moveCardFromDrawToDiscardPile(player: player, card: card)
			}
        }
    }
    
    /// Finish HandleDrawCardDeckTouch by updating view and model. This is called when a card is drawn
    /// from card deck but not played to discard pile
    ///
    /// - Parameters:
    ///   - player: player that's currently playing
    ///   - card: card that was drawn
    func doFinishHandleDrawCardDeckTouch(player: Player, card: Card) {
        // Update draw card pile
        let cardFromDeck = updateDrawPile()
        assert(card === cardFromDeck) // Just checking
        // Update draw card pile in view
        gameScene?.drawTopDrawDeckCard()
        
        // Update model
        player.drawCard(card: cardFromDeck)
        
        // Update view
        // Rearrange cards: as cards move from hand to discard pile, update cards from
        // player hand so that they are shown right next to each other. cardPosIdx corresponds
        // is to tell drawPlayerCards which players card we are adjusting in the position
        // perspective.
        gameScene?.drawPlayerCards(player: player, cardPosIdx: playersVec.index{$0 === player}!)
        
        // Update order of play
        updateOrderOfPlay(withSkip: false) // No card is played, pass skip as false
        gameScene?.drawCurrentPlayerLabel()
        
        // Go to the next player (possibly AI)
        handleAIPlayersPlay()
    }
    
    /// Finish HandleDrawCardDeckTouch by updating view and model. This is called when a card is drawn
    /// from card deck AND it is played to discard pile
    ///
    /// - Parameters:
    ///   - player: player that's currently playing
    ///   - card: card that was drawn
    func doFinishHandleDrawDeckPile(player: Player, card: Card) {
        // Update draw card pile
        let cardFromDeck = updateDrawPile()
        // Update discard pile
        updateDiscardPile(card: cardFromDeck)
        assert(card === cardFromDeck) // Just checking
        // Update draw discard pile in view
        gameScene?.drawTopDiscardPileCard()
        // Update draw card pile in view
        gameScene?.drawTopDrawDeckCard()
        
        // If the card played is wild, show in view what was the chosen color
        if card.cardType == CardType.wild {
            gameScene?.drawWildChosenColorLabel()
        } else {
            // make sure chosen color label is not displayed
            gameScene?.wildChosenColorLabel.isHidden = true
        }
        
        // if the card played is skip or reverse, adjust who will play next and the view
        let isSkip = handleSkipAndReverseCards(card: card)
        
        // Update order of play
        updateOrderOfPlay(withSkip: isSkip)
        gameScene?.drawCurrentPlayerLabel()
        
        // Go to the next player (possibly AI)
        handleAIPlayersPlay()
    }
    
    /// Check if card attempted to be played is valid.
    ///
    /// - Parameters:
    ///   - player: Player attempting to play a card
    ///   - card: Potential card to be played
    /// - Returns: True if card is valid, false otherwise
    func isPlayValid(player: Player, card: Card?) -> Bool {
        // TODO: Needs testing
        
        if card == nil {
            return false
        }
        
        // Wild card can always be played
        if card?.cardValue != CardUtils.wildCard.cardValue {
            // Check if Wild Draw Four card
            if card?.cardValue == CardUtils.wildDrawFourCard.cardValue {
                // Check card color condition
                if player.hasCardColor(cardColor: self.currentCard!.cardColor) {
                    return false
                }
            } else {
                // Check card color and value
                if (self.currentCard?.cardColor != card?.cardColor && self.currentCard?.cardValue != card?.cardValue) {
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
    ///
    /// List of steps in descending order of priority (if card to-be-played is available and valid):
    /// 0. Play either Wild Draw Four or Wild card
    ///     0.1 Play Wild Draw Four card
    ///     0.2 Play Wild card
    /// 1. Play card matching color, type (except Wild and Wild Draw Four), or value that has the highest value
    ///     1.1 Or check if action card
    ///
    /// - Parameters:
    ///   - player: current AI player that must choose card to play
    /// - Returns: card to be played
    func playAIStrategySimpleV1(player: Player, mustDraw: inout Bool) -> Card? {
        // TODO: Needs testing
        
        var playedCard: Card? = nil
        
        // Step 0.
        if player.hasCard(card: CardUtils.wildDrawFourCard) {
            playedCard = player.getCard(card: CardUtils.wildDrawFourCard)
            if self.isPlayValid(player: player, card: playedCard) {
                return playedCard
            }
        }
        if player.hasCard(card: CardUtils.wildCard) {
            playedCard = player.getCard(card: CardUtils.wildCard)
            if self.isPlayValid(player: player, card: playedCard) {
                return playedCard
            }
        }
        
        // Step 1.
        playedCard = player.getMaximumValueCard() // Exclude Wild Draw Four card (default parameter)
        
        // If there is a match in card value, no need to check colors
        if playedCard != nil && playedCard?.cardValue != currentCard?.cardValue {
            // Find maximum card of valid color
            playedCard = nil
            if currentCard?.cardColor == CardColor.blue {
                // Get blue card with maximum value
                let maxBlueCard = player.getMaximumValueCard(cardColor: CardColor.blue)
                if maxBlueCard != nil {
                    playedCard = maxBlueCard
                }
            } else if currentCard?.cardColor == CardColor.green {
                // Get green card with maximum value
                let maxGreenCard = player.getMaximumValueCard(cardColor: CardColor.green)
                if maxGreenCard != nil {
                    playedCard = maxGreenCard
                }
            } else if currentCard?.cardColor == CardColor.red {
                // Get red card with maximum value
                let maxRedCard = player.getMaximumValueCard(cardColor: CardColor.red)
                if maxRedCard != nil {
                    playedCard = maxRedCard
                }
            } else {
                // Get yellow card with maximum value
                let maxYellowCard = player.getMaximumValueCard(cardColor: CardColor.yellow)
                if maxYellowCard != nil {
                    playedCard = maxYellowCard
                }
            }
        }
        
        if playedCard == nil {
            // Does not have valid card, needs to draw one
            mustDraw = true
            playedCard = nil
            print("Must draw from deck")
        }
        
        return playedCard
    }
    
    
    /// Update controller's attributes and view when a reverse card
    /// or a skip card is played by setting who plays next.
    ///
    /// - Parameter card: Card played
    /// - Returns: Bool informing if next player should be skipped
    func handleSkipAndReverseCards(card: Card) -> Bool {
        var isSkip = false
        // If played card was a skip or reverse, do extra changes
        if card.cardValue == SpecialVals.reverse.rawValue {
            isOrderClockwise = !isOrderClockwise
            // Update play direction sprite in view
            if numOfPlayers > 2 {
                gameScene?.drawPlayDirection()
            } else { // reverse cards are treated as skip when in 2 players mode
                isSkip = true
            }
        } else if card.cardValue == SpecialVals.skip.rawValue {
            isSkip = true
        }
        return isSkip
    }
    
    /// Update currPlayerIdx value to set who plays next
    func updateOrderOfPlay(withSkip: Bool) {
        if withSkip == true {
            currPlayerIdx = isOrderClockwise ? currPlayerIdx + 2 : currPlayerIdx - 2
        } else {
            currPlayerIdx = isOrderClockwise ? currPlayerIdx + 1 : currPlayerIdx - 1
        }
        
        if currPlayerIdx >= numOfPlayers {
            currPlayerIdx = currPlayerIdx - numOfPlayers
        } else if currPlayerIdx < 0 {
            currPlayerIdx = numOfPlayers + currPlayerIdx
        }
    }
    
    
    func getNextPlayer() -> Player? {
        var nextPlayerIdx: Int = isOrderClockwise ? currPlayerIdx + 1 : currPlayerIdx - 1
        if nextPlayerIdx >= numOfPlayers {
            nextPlayerIdx = nextPlayerIdx - numOfPlayers
        } else if nextPlayerIdx < 0 {
            nextPlayerIdx = numOfPlayers + nextPlayerIdx
        }
        
        return playerOrderOfPlay[nextPlayerIdx]
    }
    
    func handleChoseColorForWildCard(player: Player, card: Card) {
        // Pick color that current player has more cards
        let chosenColor = player.getColorWithMostCards()
        // Change wild card color to chosen color
        assert(chosenColor != CardColor.other)
        card.cardColor = chosenColor
    }
    
    func doFinishDrawTwoAction(player: Player, card1: Card, card2: Card) {
        // Update draw card pile
        let cardFromDeck = updateDrawPile()
        assert(card2 === cardFromDeck) // Just checking
        // Update draw card pile in view
        gameScene?.drawTopDrawDeckCard()
        
        // Update model
        player.drawCard(card: card1)
        player.drawCard(card: card2)
        
        // Update view
        // Rearrange cards: as cards move from hand to discard pile, update cards from
        // player hand so that they are shown right next to each other. cardPosIdx corresponds
        // is to tell drawPlayerCards which players card we are adjusting in the position
        // perspective.
        gameScene?.drawPlayerCards(player: player, cardPosIdx: playersVec.index{$0 === player}!)
    }
}
