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
    var cardDeckRepository: [Card?] = [] // Stores popped cards from card deck
    
    var playersVec: [Player?] = [] // Array that contains all players in the game
    var numOfPlayers: Int = 0 // Determines how many players are participating in the game
    
    var playerOrderOfPlay: [Player?] = [] // Array that determines the order of play
    var currPlayerIdx: Int = 0 // Index of the player who is currently playing
    var isOrderClockwise: Bool = true // Determines direction of play
    
    var menuScene: MenuScene? // Stores MenuScene object
    var gameScene: GameScene? // Stores GameScene object
    var currentCard: Card? = nil // Current card on the table
    
    let listOfPlaceholderNames = ["Brett Boe", "Carla Coe", "Donna Doe", "Frank Foe", "Grace Goe", "Harry Hoe", "Jackie Joe", "Jane Doe", "Jane Poe", "Jane Roe", "John Doe", "John Smith", "Karren Koe", "Larry Loe", "Mark Moe", "Marta Moe", "Norma Noe", "Paula Poe", "Quintin Qoe", "Ralph Roe", "Sammy Soe", "Tommy Toe", "Vince Voe", "William Woe", "Xerxes Xoe", "Yvonne Yoe", "Zachery Zoe"] // Used for AI players
    
    let listOfAIStrategies = ["v1", "v2"] // List of AI play strategies
    
    var playerPoints: [Int: Int] = [:] // Dictionary of players' points
    var currentRoundCounter: Int = 0 // Counter for the current round
    var roundWinnder: Player! // Winner of the current round
    var nonAIPlayerName: String = "Me" // Non-AI player's name
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true // Prevent "Warning: Attempt to present * on * which is already presenting" due to UIAlertController
        
//        // Load card deck
//        CardUtils.loadDeck()
//        
//        // Shuffle card deck
//        CardUtils.shuffleDeck()
//        
//        // Populate stack of cards
//        for card in CardUtils.getCardDeck() {
//            cardDeck.push(card)
//        }
        
//        // Load first round
//        loadRound()
//        
//        // Create state machines
//        createStateSm()
//        
//        // Present main menu
//        menuScene = MenuScene(size: view.bounds.size)
//        menuScene?.viewController = self
//        let skView = view as! SKView
//        skView.showsFPS = false
//        skView.showsNodeCount = false
//        skView.ignoresSiblingOrder = false // Draw background first, then cards
//        menuScene?.scaleMode = .resizeFill
//        skView.presentScene(menuScene)
        
        // Start scenes and initialize necessary members
        startGame()
        
        // Add observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePlayerCardTouch), name: Notification.Name("handlePlayerCardTouch"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleDrawCardDeckTouch), name: Notification.Name("handleDrawCardDeckTouch"), object: nil)
    }
    
    
    /// Initialize all necessary data to start a game
    func startGame() {
        // Load first round
        loadRound()
        
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
    }
    
    
    /// Load current round
    func loadRound() {
        // Remove cards from table, if any
        let players = playersVec
        for player in players {
            let cards = player?.getCards()
            
            for card in cards! {
                card?.removeFromParent()
            }
        }
        if !discardPile.isEmpty() {
            discardPile.peek()?.removeFromParent()
        }
        
        // Update points labels
        gameScene?.updatePlayersPoints()
        
        // Load card deck
        CardUtils.loadDeck()
        
        // Shuffle card deck
        CardUtils.shuffleDeck()
        
        // Populate stack of cards
        for card in CardUtils.getCardDeck() {
            cardDeck.push(card)
        }
        
        // Hand cards to players
        let initNumOfCards : Int = 7
        for i in 0..<numOfPlayers {
            var cards = [Card?](repeating: nil, count: initNumOfCards)
            for j in 0..<initNumOfCards {
                cards[j] = cardDeck.pop()
            }
            
            playersVec[i]?.setCards(cards: cards as! [Card])
        }
        
        // Update round counter
        currentRoundCounter += 1
        
        // Round two and on
        if !playersVec.isEmpty {
            // Now that we have the players created, let's set an order of play
            setOrderOfPlay()
            
            // Now it's time to create the discard pile
            initDiscardPile()
            
            // Initialize view
            isOrderClockwise = true
            gameScene?.initRound()
        }
    }
    
    
    /// Reset all members for the start of a new game
    func resetMembers() {
        // IMPORTANT: Add initialization of new members here every time a new member that needs initialization is created for the class
        cardDeck = Stack<Card?>()
        discardPile = Stack<Card?>()
        cardDeckRepository.removeAll()
        
        playersVec.removeAll()
        numOfPlayers = 0
        
        playerOrderOfPlay.removeAll()
        currPlayerIdx = 0
        isOrderClockwise = true
        
        currentCard = nil
        
        playerPoints.removeAll()
        currentRoundCounter = 0
        nonAIPlayerName = "Me"
    }
    
    
    /// Create state machine
    func createStateSm() {
        stateMachine = GKStateMachine(states: [menuState, gamePlayState, endGameState])
    }
    
    
    /// Initialize array of players
    func initPlayers() {
        playersVec = [Player?](repeating: nil, count: numOfPlayers)
        let AINameIndices = Array(0...listOfPlaceholderNames.count - 1).shuffled()
        let initNumOfCards : Int = 7
        for i in 0..<numOfPlayers {
            var cards = [Card?](repeating: nil, count: initNumOfCards)
            for j in 0..<initNumOfCards {
                cards[j] = cardDeck.pop()
            }
            
            if i == 0 {
                playersVec[i] = Player(cards: cards, name: nonAIPlayerName, AIStatus: i != 0)
            } else {
                playersVec[i] = Player(cards: cards, name: listOfPlaceholderNames[AINameIndices[i]], AIStatus: i != 0)
            }
        }
        
        // Initialize players' points if first round
        if playerPoints.count == 0 {
            // First round
            for i in 0..<numOfPlayers {
                playerPoints[i] = 0
            }
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
        let lower: UInt32 = 0
        let upper: UInt32 = UInt32(numOfPlayers - 1)
        currPlayerIdx = Int(arc4random_uniform(upper - lower) + lower)
//        currPlayerIdx = numOfPlayers <= 3 ? 1 : 2 // Uncomment this to test first play by non-AI player
        if playerOrderOfPlay[currPlayerIdx]!.isAI() {
            handleAIPlayersPlay()
        }
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
    
    
    /// Restore card deck when number of cards left is less than or equal to 4
    func restoreCardDeck() {
        print("Restoring played cards to card deck")
        cardDeckRepository.shuffle()
        for card in cardDeckRepository {
            cardDeck.push(card)
        }
        cardDeckRepository.removeAll()
    }
    
    
    /// Handle play by AI player
    func handleAIPlayersPlay() {
        let delayInSeconds = 1.7
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            let player = self.playerOrderOfPlay[self.currPlayerIdx]
            if (player?.isAI())! {
                print("\n\(player!.getName())'s cards")
                print(player!.toString())
                
                // Randomly choose strategy to play
                var mustDraw: Bool = false
                let lower: UInt32 = 0
                let upper: UInt32 = UInt32(self.listOfAIStrategies.count)
                let strategyIdx = Int(arc4random_uniform(upper - lower) + lower)
                var card: Card? = nil
                switch self.listOfAIStrategies[strategyIdx] {
                    case "v1":
                        card = self.playAIStrategyV1(player: player!, mustDraw: &mustDraw)
                    case "v2":
                        card = self.playAIStrategyV2(player: player!, mustDraw: &mustDraw)
                    default:
                        card = self.playAIStrategyV1(player: player!, mustDraw: &mustDraw)
                }
//                let card = self.playAIStrategySimpleV1(player: player!, mustDraw: &mustDraw)
                
                if card != nil {
                    // If card is wild, AI will have to choose a color for it
                    if card?.cardType == CardType.wild {
                        self.handleChosenColorForWildCard(player: player!, card: card!)
                    }
                    
                    // Update model and view
                    self.gameScene?.moveCardFromHandToDiscardPile(player: player!, card: card!)
                    self.gameScene?.drawCurrentPlayerLabel()
                    
                    print("Card played")
                    print(card!.toString())
                } else {
                    if mustDraw {
                        let drawnCard = self.cardDeck.peek()
                        if self.isPlayValid(player: player!, card: drawnCard) {
                            // If card is wild, AI will have to choose a color for it
                            if drawnCard?.cardType == CardType.wild {
                                self.handleChosenColorForWildCard(player: player!, card: drawnCard!)
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
            }
        }
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
        if player.getCards().count == 0 {
            // End of round
            handleEndOfRound(winnerID: playersVec.index{$0 === player}!, lastPlayedCard: card)
        } else if player.getCards().count == 1 && !player.isAI() {
            // Show uno button, human player has to click on
            // it before the timeout
            gameScene?.drawUnoButton(player: player, card: card)
        } else {
            doFinishHandlePlayerCardTouchFinally(player: player, card: card)
        }
    }
    
    
    /// Event handler of the card chosen by the non-AI player
    ///
    /// - Parameter notification: Dictionary containing the non-AI player and the touched card
    func handleDrawCardDeckTouch(notification: Notification) {
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
        cardDeckRepository.append(cardFromDeck) // Update repository
        if cardDeck.count() <= 4 {
            restoreCardDeck()
        }
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
        cardDeckRepository.append(cardFromDeck) // Update repository
        if cardDeck.count() <= 4 {
            restoreCardDeck()
        }
        // Update draw discard pile in view
        gameScene?.drawTopDiscardPileCard()
        // Update draw card pile in view
        gameScene?.drawTopDrawDeckCard()
        
        // Update model
        player.playCard(card: card)
        
        // Go to the next player (possibly AI)
        if player.getCards().count == 0 {
            // End of round
            handleEndOfRound(winnerID: playersVec.index{$0 === player}!, lastPlayedCard: card)
        } else if player.getCards().count == 1 && !player.isAI() {
            // Show uno button, human player has to click on
            // it before the timeout
            gameScene?.drawUnoButton(player: player, card: card)
        } else {
            // If the card played is wild, show in view what was the chosen color
            if card.cardType == CardType.wild {
                gameScene?.drawWildChosenColorLabel()
            } else {
                // make sure chosen color label is not displayed
                gameScene?.wildChosenColorLabel.isHidden = true
            }
            
            // if the card played is skip or reverse, adjust who will play next and the view
            var isSkip = handleSkipAndReverseCards(card: card)
            
            // Check if Draw Two card
            if card.cardValue == SpecialVals.drawTwo.rawValue {
                // Check if card deck has fewer than two cards
                if cardDeck.count() < 2 {
                    // TODO: End round (not enough cards)
                    print("Card deck has fewer than 2 cards")
                } else {
                    // Skip next player
                    isSkip = true
                    
                    // Get next player
                    let nextPlayer = getNextPlayer()
                    assert(nextPlayer != nil)
                    
                    // Add two cards to the next player's hand
                    // Add animation to card moving from draw pile to player's hand
                    // After completing the animation, doFinishDrawTwoAction will be called
                    gameScene?.moveCardFromDrawToPlayerHandDrawTwoOrFourAction(player: nextPlayer!, cardPosIdx: playersVec.index{$0 === nextPlayer}!, card1: updateDrawPile(), card2: cardDeck.peek()!)
                }
            }
            
            // Check if Wild Draw Four card
            if card.cardValue == SpecialVals.wildDrawFour.rawValue {
                // Check if card deck has fewer than four cards
                if cardDeck.count() < 4 {
                    // TODO: End round (not enough cards)
                    print("Card deck has fewer than 4 cards")
                } else {
                    // Skip next player
                    isSkip = true
                    
                    // Get next player
                    let nextPlayer = getNextPlayer()
                    assert(nextPlayer != nil)
                    
                    // Add two cards to the next player's hand
                    // Add animation to card moving from draw pile to player's hand
                    // After completing the animation, doFinishDrawTwoAction will be called
                    gameScene?.moveCardFromDrawToPlayerHandDrawTwoOrFourAction(player: nextPlayer!, cardPosIdx: playersVec.index{$0 === nextPlayer}!, card1: updateDrawPile(), card2: updateDrawPile(), card3: updateDrawPile(), card4: cardDeck.peek()!)
                }
            }
            
            // Update order of play
            updateOrderOfPlay(withSkip: isSkip)
            gameScene?.drawCurrentPlayerLabel()
            
            // Go to the next player (possibly AI)
            handleAIPlayersPlay()
        }
    }
    
    /// Check if card attempted to be played is valid.
    ///
    /// - Parameters:
    ///   - player: Player attempting to play a card
    ///   - card: Potential card to be played
    /// - Returns: True if card is valid, false otherwise
    func isPlayValid(player: Player, card: Card?) -> Bool {
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
    
    
    /// Get all valid cards for an AI player
    ///
    /// - Parameter player: AI player
    /// - Returns: All valid cards of the player
    func playAIStrategyAllValidCards(player: Player) -> [Card] {
        var allValidCards: [Card] = []
        
        // Wild Draw Four
        if player.hasCard(card: CardUtils.wildDrawFourCard) {
            let playedCard = player.getCard(card: CardUtils.wildDrawFourCard)
            if self.isPlayValid(player: player, card: playedCard) {
                allValidCards.append(playedCard!)
            }
        }
        
        // Wild
        if player.hasCard(card: CardUtils.wildCard) {
            let playedCard = player.getCard(card: CardUtils.wildCard)
            if self.isPlayValid(player: player, card: playedCard) {
                allValidCards.append(playedCard!)
            }
        }
        
        
        // Get all other valid cards
        let cards = player.getCards()
        for card in cards {
            if self.isPlayValid(player: player, card: card) {
                allValidCards.append(card!)
            }
        }
        
        return allValidCards
    }
    
    /// Strategy for AI player (version 1).
    ///
    /// Main objective: play valid card of highest value.
    /// Does use any game feedback information.
    ///
    /// - Parameters:
    ///   - player: AI player
    /// - Returns: Card to be played, nil if must draw from deck
    func playAIStrategyV1(player: Player, mustDraw: inout Bool) -> Card? {
        var playedCard: Card? = nil
        
        let allValidCards = self.playAIStrategyAllValidCards(player: player)
        if allValidCards.count > 0 {
            playedCard = allValidCards.max{$0.cardValue < $1.cardValue}
        }
        
        if playedCard == nil {
            // Does not have valid card, needs to draw one
            mustDraw = true
            playedCard = nil
            print("Must draw from deck")
        }
        
        return playedCard
    }
    
    
    /// Strategy for AI player (version 2).
    ///
    /// Main objective: play a random valid card.
    /// Does use any game feedback information.
    ///
    /// - Parameters:
    ///   - player: AI player
    /// - Returns: Card to be played, nil if must draw from deck
    func playAIStrategyV2(player: Player, mustDraw: inout Bool) -> Card? {
        var playedCard: Card? = nil
        
        let allValidCards = self.playAIStrategyAllValidCards(player: player)
        if allValidCards.count > 0 {
            let lower: UInt32 = 0
            let upper: UInt32 = UInt32(allValidCards.count - 1)
            let cardIdx = Int(arc4random_uniform(upper - lower) + lower)
            playedCard = allValidCards[cardIdx]
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
    ///
    /// - Parameter withSkip: True if skip play, false otherwise
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
    
    
    
    /// Get next player in the order of play
    ///
    /// - Returns: Next player to play
    func getNextPlayer() -> Player? {
        var nextPlayerIdx: Int = isOrderClockwise ? currPlayerIdx + 1 : currPlayerIdx - 1
        if nextPlayerIdx >= numOfPlayers {
            nextPlayerIdx = nextPlayerIdx - numOfPlayers
        } else if nextPlayerIdx < 0 {
            nextPlayerIdx = numOfPlayers + nextPlayerIdx
        }
        
        return playerOrderOfPlay[nextPlayerIdx]
    }
    
    
    /// Handle chosen color when Wild card is played
    ///
    /// - Parameters:
    ///   - player: Current player
    ///   - card: Wild card
    func handleChosenColorForWildCard(player: Player, card: Card) {
        // Pick color that current player has more cards
        let chosenColor = player.getColorWithMostCards()
        // Change wild card color to chosen color
        assert(chosenColor != CardColor.other)
        card.cardColor = chosenColor
    }
    
    
    /// Finalize animation for Draw Two and Wild Draw Four cards
    ///
    /// - Parameters:
    ///   - player: Player receiving additional cards
    ///   - card1: First card
    ///   - card2: Second card
    ///   - card3: Third card (default: nil)
    ///   - card4: Fourth card (default: nil)
    func doFinishDrawTwoOrFourAction(player: Player, card1: Card, card2: Card, card3: Card? = nil, card4: Card? = nil) {
        // Update draw card pile
        let cardFromDeck = updateDrawPile()
        cardDeckRepository.append(card1) // Update repository
        cardDeckRepository.append(card2) // Update repository
        if card4 == nil {
            assert(card2 === cardFromDeck) // Just checking
        } else {
            assert(card4! === cardFromDeck) // Just checking
            cardDeckRepository.append(card3) // Update repository
            cardDeckRepository.append(cardFromDeck) // Update repository
        }
        if cardDeck.count() <= 4 {
            restoreCardDeck()
        }
        // Update draw card pile in view
        gameScene?.drawTopDrawDeckCard()
        
        // Update model
        player.drawCard(card: card1)
        player.drawCard(card: card2)
        if card3 != nil && card4 != nil {
            player.drawCard(card: card3!)
            player.drawCard(card: card4!)
        }
        
        // Update view
        // Rearrange cards: as cards move from hand to discard pile, update cards from
        // player hand so that they are shown right next to each other. cardPosIdx corresponds
        // is to tell drawPlayerCards which players card we are adjusting in the position
        // perspective.
        gameScene?.drawPlayerCards(player: player, cardPosIdx: playersVec.index{$0 === player}!)
    }
    
    
    /// Handle end of a round
    ///
    /// - Parameter winnerID: ID of the winning player (e.g., `playersVec.index{$0 === player}!`)
    func handleEndOfRound(winnerID: Int, lastPlayedCard: Card) {
        // Add up cards' points from all other players
        var sumPoints: Int = 0
        for playerID in 0..<numOfPlayers {
            if playerID != winnerID {
                let cards = playersVec[playerID]!.getCards()
                for card in cards {
                    sumPoints += card!.cardPoints
                }
            }
        }
        
        // Update points of the winner
        self.playerPoints[winnerID]! += sumPoints
        self.playersVec[winnerID]?.setPoints(points: self.playerPoints[winnerID]!)
        roundWinnder = self.playersVec[winnerID]!
        
        // Print players' points
        for playerID in 0..<numOfPlayers {
            print(playersVec[playerID]!.getName() + ": " + String(playersVec[playerID]!.getPoints()))
        }
        
        // Show all players' cards
        gameScene?.showAllPlayersCards()
        
        // Remove last played card from table
        lastPlayedCard.removeFromParent()
        
        // Check for end of game
        if roundWinnder.getPoints() >= 500 {
            // Display end of game alert
            showEndOfGameAlertButtonTapped()
        } else {
            // Display end of round alert
            showEndOfRoundAlertButtonTapped()
        }
    }
    
    
    /// Alert end of round
    func showEndOfRoundAlertButtonTapped() {
        // Create the alert
        let alert = UIAlertController(title: "End of Round " + String(currentRoundCounter), message: roundWinnder.getName() + " wins!", preferredStyle: UIAlertControllerStyle.alert)
        
        // Add the actions (buttons)
        alert.addAction(UIAlertAction(title: "New Round", style: UIAlertActionStyle.default, handler: {action in
            self.loadRound()
        }))
        alert.addAction(UIAlertAction(title: "Start Over", style: UIAlertActionStyle.destructive, handler: {action in
            // Go to round 1 with the same configuration of players
//            self.currentRoundCounter = 0
//            for playerIdx in 0..<self.numOfPlayers {
//                self.playerPoints[playerIdx] = 0
//                self.playersVec[playerIdx]?.resetPoints()
//            }
//            self.loadRound()
            
            // Start the game from scratch
            self.resetMembers()
            self.gameScene?.removeFromParent()
            self.startGame()
        }))
    
        // Show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Alert end of game
    func showEndOfGameAlertButtonTapped() {
        // Create the alert
        let alert = UIAlertController(title: "End of Round " + String(currentRoundCounter), message: roundWinnder.getName() + " wins the game with\n" + String(roundWinnder.getPoints()) + " points!", preferredStyle: UIAlertControllerStyle.alert)
        
        // Add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Start Over", style: UIAlertActionStyle.destructive, handler: {action in
            // Go to round 1 with the same configuration of players
//            self.currentRoundCounter = 0
//            for playerIdx in 0..<self.numOfPlayers {
//                self.playerPoints[playerIdx] = 0
//                self.playersVec[playerIdx]?.resetPoints()
//            }
//            self.loadRound()
            
            // Start the game from scratch
            self.resetMembers()
            self.gameScene?.removeFromParent()
            self.startGame()
        }))
        
        // Show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func doFinishHandlePlayerCardTouchFinally(player: Player, card: Card) {
        // Update discard pile
        updateDiscardPile(card: card)
        
        // if the card played is skip or reverse, adjust who will play next and the view
        var isSkip: Bool = handleSkipAndReverseCards(card: card)
        
        // Check if Draw Two card
        if card.cardValue == SpecialVals.drawTwo.rawValue {
            // Skip next player
            isSkip = true
            
            // Get next player
            let nextPlayer = getNextPlayer()
            assert(nextPlayer != nil)
            
            // Add two cards to the next player's hand
            // Add animation to card moving from draw pile to player's hand
            // After completing the animation, doFinishDrawTwoAction will be called
            gameScene?.moveCardFromDrawToPlayerHandDrawTwoOrFourAction(player: nextPlayer!, cardPosIdx: playersVec.index{$0 === nextPlayer}!, card1: updateDrawPile(), card2: cardDeck.peek()!)
        }
        
        // Check if Wild Draw Four card
        if card.cardValue == SpecialVals.wildDrawFour.rawValue {
            // Skip next player
            isSkip = true
            
            // Get next player
            let nextPlayer = getNextPlayer()
            assert(nextPlayer != nil)
            
            // Add two cards to the next player's hand
            // Add animation to card moving from draw pile to player's hand
            // After completing the animation, doFinishDrawTwoAction will be called
            gameScene?.moveCardFromDrawToPlayerHandDrawTwoOrFourAction(player: nextPlayer!, cardPosIdx: playersVec.index{$0 === nextPlayer}!, card1: updateDrawPile(), card2: updateDrawPile(), card3: updateDrawPile(), card4: cardDeck.peek()!)
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

}


// MARK: - Needed to make actions of UIAlertAction work
extension UIViewController {
    func showAlertControllerWithTitle(title:String?,message:String?,actions:[UIAlertAction],dismissingActionTitle:String?, dismissBlock:(() -> ())?) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if dismissingActionTitle != nil {
            let okAction = UIAlertAction(title: dismissingActionTitle, style: .default) { (action) -> Void in
                dismissBlock?()
                alertController.dismiss(animated:true, completion:nil)
            }
            alertController.addAction(okAction)
        }
        for action in actions {
            alertController.addAction(action)
        }
        self.present(alertController, animated: true, completion:nil)
        return alertController
    }
}
