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
	var currPlayerLabel = SKLabelNode(text: "")
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
            let cards = player?.getCards()
            var xPos = cardPositions[cardPosIdx].x
            var yPos = cardPositions[cardPosIdx].y
            for card in cards! {
                card?.position = CGPoint(x: xPos, y: yPos)
                card?.setScale(0.2)
                // Draw frontTexture if it's human player, otherwise draw backTexture
                card?.texture = (player?.isAI())! ? card?.backTexture : card?.frontTexture
                // TODO: rotate cards depending on what player this is
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
            cardPosIdx += 1
        }
		
		// Draw labels for players' names
		drawPlayersNames()
		
		// Draw label for current player
		drawCurrentPlayerLabel()
		
		// Draw discard pile
		drawTopDiscardPileCard()
		
		// Draw playDirection node, but only if number of players > 2
		if viewController.numOfPlayers > 2 {
			drawPlayDirection()
		}
    }
	
	/// Draw label that informs who's playing currently
	func drawCurrentPlayerLabel() {
		currPlayerLabel.position = CGPoint(x: size.width * 0.9, y: size.height * 0.94)
		currPlayerLabel.fontSize = 13
		currPlayerLabel.fontName = "AvenirNext-Bold"
		currPlayerLabel.text =
			(viewController.playerOrderOfPlay[viewController.currPlayerIdx]?.getName())! + "'s turn"
		background.addChild(currPlayerLabel)
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
		background.addChild(topDiscardPileCard!)
	}
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node: SKNode = self.atPoint(location)
            
            if node == viewController.currentCard {
                // TODO: Change the condition to the player's picked card to play
                // TODO: Fully handle the event
                // Touched current card in the pile
                
                // Post notification
                NotificationCenter.default.post( name: Notification.Name("handlePlayerCardTouch"), object: node)
            }
        }
    }
}
