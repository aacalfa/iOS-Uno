//
//  GameScene.swift
//  Uno
//
//  Created by Andre Calfa on 3/4/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var background = SKSpriteNode(imageNamed: "Table") // sprite for table texture
    var viewController: GameViewController!
	
    var cardPositions: [CGPoint] = [] // Location of cards
	
	var playDirection = SKSpriteNode(imageNamed: "Clockwise") // Show if play is clockwise or anti-clockwise
    let invalidPlayLabel = SKLabelNode(text: "Invalid play!")
	var currPlayerLabel = SKLabelNode(text: "")
    var wildChosenColorLabel = SKLabelNode(text: "")
	var playerNames: [SKLabelNode] = [] // Labels for players' names
	
    override func didMove(to view: SKView) {
        // Draw backgorund
        addChild(background)
        
        // Define where to place cards on screen
        setCardLocations()
        
        // Draw players cards
        var cardPosIdx = 0
        let playersVec = viewController.playersVec
        for player in playersVec {
            drawPlayerCards(player: player, cardPosIdx: cardPosIdx)
            cardPosIdx += 1
        }
		
		// Draw labels for players' names
		drawPlayersNames()
		
		// Draw label for current player
		drawCurrentPlayerLabel()
		
		// Draw discard pile
		drawTopDiscardPileCard()
        
        // Draw card deck
        drawTopDrawDeckCard()
		
		// Draw playDirection node, but only if number of players > 2
		if viewController.numOfPlayers > 2 {
			drawPlayDirection()
		}
        
        // Initialize properties of invalid play label and make it hidden
        invalidPlayLabel.fontSize = 13
        invalidPlayLabel.fontName = "AvenirNext-Bold"
        let topDiscardPileCard = viewController.currentCard
        invalidPlayLabel.position = CGPoint(x: (topDiscardPileCard?.position.x)!, y: (topDiscardPileCard?.position.y)! - (topDiscardPileCard?.size.height)!)
        invalidPlayLabel.isHidden = true
        background.addChild(invalidPlayLabel)
    }
    
    func drawPlayerCards(player: Player?, cardPosIdx: Int) {
        let cards = player?.getCards()
        var xPos = cardPositions[cardPosIdx].x
        var yPos = cardPositions[cardPosIdx].y
        
        for card in cards! {
            // If cards currently exist, remove them so they'll get rearranged
            card?.removeFromParent()
            
            card?.position = CGPoint(x: xPos, y: yPos)
            card?.setScale(0.2)
            // Draw frontTexture if it's human player, otherwise draw backTexture
            card?.texture = (player?.isAI())! ? card?.backTexture : card?.frontTexture
            if cardPosIdx == 1 {
                card?.zRotation = CGFloat(M_PI)
            } else if cardPosIdx == 2 {
                card?.zRotation = CGFloat(-M_PI / 2)
            } else if cardPosIdx == 3 {
                card?.zRotation = CGFloat(M_PI / 2)
            }
            background.addChild(card!)
            
            // player 0 and 1 cards are distributed horizontally through the screen,
            // whereas players 2 and 3 cards are distributed vertically
            if cardPosIdx <= 1 {
                xPos += (card?.texture?.size().width)! / 6
            } else {
                yPos += (card?.texture?.size().width)! / 6
            }
            
        }
    }
	
	/// Draw label that informs the current player
	func drawCurrentPlayerLabel() {
        currPlayerLabel.removeFromParent()
		currPlayerLabel.position = CGPoint(x: size.width * 0.9, y: size.height * 0.94)
		currPlayerLabel.fontSize = 13
		currPlayerLabel.fontName = "AvenirNext-Bold"
		currPlayerLabel.text = (viewController.playerOrderOfPlay[viewController.currPlayerIdx]?.getName())! + "'s turn"
		background.addChild(currPlayerLabel)
	}
    
    /// Draw label that informs what color has been chose for wild card
    func drawWildChosenColorLabel() {
        let topDiscardPileCard = viewController.currentCard
        wildChosenColorLabel.removeFromParent()
        wildChosenColorLabel.position = CGPoint(x: (topDiscardPileCard?.position.x)!, y: (topDiscardPileCard?.position.y)! + (topDiscardPileCard?.size.height)!)
        wildChosenColorLabel.fontSize = 13
        wildChosenColorLabel.fontName = "AvenirNext-Bold"
        wildChosenColorLabel.fontColor = topDiscardPileCard?.colorAsUIColor()
        wildChosenColorLabel.text = "Chosen color is: " + (topDiscardPileCard?.colorAsString())!
        wildChosenColorLabel.isHidden = false
        background.addChild(wildChosenColorLabel)
    }
	
	/// Draw players' names labels
	func drawPlayersNames() {
		let playersVec = viewController.playersVec
		var i = 0
		for player in playersVec {
			let playerNameLabel = SKLabelNode(text: player?.getName())
			playerNameLabel.fontSize = 13
			playerNameLabel.fontName = "AvenirNext-Bold"
			var position = cardPositions[i]
			// fixMe: find a better way to set the position
			if i < 2 {
				position.x -= 60
			} else {
				position.y -= 60
			}
			playerNameLabel.position = position
			playerNames.append(playerNameLabel)
			background.addChild(playerNames[i])
			i += 1
		}
	}
	
	/// Draw sprite that shows if the order is clockwise or anticlockwise
	func drawPlayDirection() {
        playDirection.removeFromParent()
        playDirection.texture = viewController.isOrderClockwise ?
            SKTexture(imageNamed: "Clockwise") : SKTexture(imageNamed: "AntiClockwise")
		playDirection.position = CGPoint(x: size.width * 0.06, y: size.height * 0.94)
		playDirection.setScale(0.3)
		background.addChild(playDirection)
	}
	
	/// Draw card on top of discard pile
	func drawTopDiscardPileCard() {
        let topDiscardPileCard = viewController.currentCard
        topDiscardPileCard?.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        topDiscardPileCard?.setScale(0.2)
        topDiscardPileCard?.texture = topDiscardPileCard?.frontTexture
        topDiscardPileCard?.zRotation = CGFloat(M_PI / 2)
        topDiscardPileCard?.removeFromParent()
        background.addChild(topDiscardPileCard!)
	}
    
    /// Draw card on top of draw deck
    func drawTopDrawDeckCard() {
        let topDrawDeckCard = viewController.cardDeck.peek()
        topDrawDeckCard?.position = CGPoint(x: self.size.width / 2 - (topDrawDeckCard?.size.width)! / 3, y: self.size.height / 2)
        topDrawDeckCard?.setScale(0.2)
        topDrawDeckCard?.texture = topDrawDeckCard?.backTexture
        topDrawDeckCard?.zRotation = CGFloat(M_PI / 2)
        topDrawDeckCard?.removeFromParent()
        background.addChild(topDrawDeckCard!)
    }
    
    /// Set card locations
    func setCardLocations() {
        let player1CardPosition = CGPoint(x: size.width * 0.3, y: size.height * 0.1)
        let player2CardPosition = CGPoint(x: size.width * 0.3, y: size.height * 0.89)
        let player3CardPosition = CGPoint(x: size.width * 0.06, y: size.height * 0.2)
        let player4CardPosition = CGPoint(x: size.width * 0.94, y: size.height * 0.2)
        cardPositions.append(player1CardPosition)
        cardPositions.append(player2CardPosition)
		cardPositions.append(player3CardPosition)
		cardPositions.append(player4CardPosition)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    /// Handles touches on the game scene UI
    ///
    /// - Parameters:
    ///   - touches: Reference to touches on the UI
    ///   - event: Reference to touch event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node: SKNode = self.atPoint(location)
            
            if node is Card {
                let card = (node as? Card)!
                let player = viewController.playerOrderOfPlay[viewController.currPlayerIdx]!
                if !player.isAI() && player.hasCardObject(card: card) {
                    // Non-AI player attempts to play
                    NotificationCenter.default.post( name: Notification.Name("handlePlayerCardTouch"), object: ["player": player, "card": card])
                } else if node === viewController.cardDeck.peek() {
                    if !player.isAI() {
                        // Drawn card from deck
                        var decidedToPlay: Bool = false // decision made by player whether to use card or not
                        
                        if viewController.isPlayValid(player: player, card: card) {
                            // TODO: ask player if he/she wants to play card or keep it
                            //decidedToPlay = true
                        }
                        
                        NotificationCenter.default.post( name: Notification.Name("handleDrawCardDeckTouch"), object: ["player": player, "card": card, "decidedToPlay": decidedToPlay])
                    }
                }
            }
        }
    }
    
    /// Animates the card being played by moving it to the discard player
    ///
    /// - Parameters:
    ///   - player: Player that's currently playing
    ///   - card: Card that will be moved
    func moveCardFromHandToDiscardPile(player: Player, card: Card) {
        card.texture = card.frontTexture
        let moveTo = viewController.currentCard?.position
        let move = SKAction.move(to: moveTo!, duration: 1)
        card.run(move, completion: { self.viewController.doFinishHandlePlayerCardTouch(player: player, card: card) })
    }
    
    /// Animates the card being moved from draw pile to player's hand
    ///
    /// - Parameters:
    ///   - player: Player who drew card
    ///   - cardPosIdx: Defines where to move the card to
    ///   - card: Card moved from draw pile
    func moveCardFromDrawToPlayerHand(player: Player, cardPosIdx: Int, card: Card, updateOrder: Bool = true) {
        self.invalidPlayLabel.isHidden = true
        card.texture = player.isAI() ? card.backTexture : card.frontTexture
        card.zRotation = 0
        let moveTo = cardPositions[cardPosIdx]
        let move = SKAction.move(to: moveTo, duration: 1)
        card.run(move, completion: { self.viewController.doFinishHandleDrawCardDeckTouch(player: player, card: card) })
        
    }
    
    /// Animates the card being moved from draw pile to discard pile
    ///
    /// - Parameters:
    ///   - player: Player who drew card
    ///   - cardPosIdx: Defines where to move the card to
    ///   - card: Card moved from draw pile
    func moveCardFromDrawToDiscardPile(player: Player, card: Card) {
        self.invalidPlayLabel.isHidden = true
        card.texture = card.frontTexture
        let moveTo = viewController.discardPile.peek()!.position
        let move = SKAction.move(to: moveTo, duration: 1)
        card.run(move, completion: { self.viewController.doFinishHandleDrawDeckPile(player: player, card: card) })
        
    }
}
