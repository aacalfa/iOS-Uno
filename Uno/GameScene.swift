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
	
	override func didMove(to view: SKView) {
        
        addChild(background)

		var xPos = size.width * 0.1
		let yPos = size.height * 0.5
		
		let cardDeck = CardUtils.getCardDeck()
		
		// Load 7 random cards
		let lower : UInt32 = 0
		let upper : UInt32 = 107

		for _ in 1...7 {
			let randomNumber = arc4random_uniform(upper - lower) + lower
			if let card: Card = cardDeck[Int(randomNumber)] {
				card.position = CGPoint(x: xPos, y: yPos)
				card.setScale(0.3)
				card.texture = card.backTexture
				background.addChild(card)
				xPos += (card.texture?.size().width)! / 4
			}
		}
		
		
		// TODO: create hand for every player, discard stack and draw stack 
	}
	
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
}
