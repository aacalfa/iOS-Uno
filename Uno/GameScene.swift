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
	
	//let card = SKSpriteNode(imageNamed: "Red_0")
	let card = Card(cardType: CardType.number, cardColor: CardColor.red, cardValue: 1)
	
	override func didMove(to view: SKView) {
		backgroundColor = SKColor.white
		
		card.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
		card.setScale(0.3)
		self.addChild(card)
	}
	
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
}
