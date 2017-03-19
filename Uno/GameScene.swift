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
    var background = SKSpriteNode(imageNamed: "Table")
    var viewController: GameViewController!
    var player1CardPosition : CGPoint?
    var player2CardPosition : CGPoint?
    var player3CardPosition : CGPoint?
    var player4CardPosition : CGPoint?
    var cardPositions: [CGPoint] = []
	
	var currPlayerLabel = SKLabelNode(text: "")
	
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
		
		// Draw discard pile
		drawTopDiscardPileCard()
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
        player1CardPosition = CGPoint(x: size.width * 0.3, y: size.height * 0.1)
        player2CardPosition = CGPoint(x: size.width * 0.3, y: size.height * 0.9)
        player3CardPosition = CGPoint(x: size.width * 0.06, y: size.height * 0.2)
        player4CardPosition = CGPoint(x: size.width * 0.94, y: size.height * 0.2)
        cardPositions.append(player1CardPosition!)
        cardPositions.append(player2CardPosition!)
		cardPositions.append(player3CardPosition!)
		cardPositions.append(player4CardPosition!)
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
