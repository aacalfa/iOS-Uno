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
    
    override func didMove(to view: SKView) {
        
        // Draw backgorund
        addChild(background)
        
        // Define where to cards on screen
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
                background.addChild(card!)
                
                // TODO: update xPos or yPos depending what player this is
                xPos += (card?.texture?.size().width)! / 6
            }
            cardPosIdx += 1
        }
    }
    
    func setCardLocations() {
        player1CardPosition = CGPoint(x: size.width * 0.3, y: size.height * 0.1)
        player2CardPosition = CGPoint(x: size.width * 0.3, y: size.height * 0.9)
        // TODO: verify values below
        player3CardPosition = CGPoint(x: size.width * 0.1, y: size.height * 0.3)
        player4CardPosition = CGPoint(x: size.width * 0.7, y: size.height * 0.3)
        cardPositions.append(player1CardPosition!)
        cardPositions.append(player2CardPosition!)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
}
