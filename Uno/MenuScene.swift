//
//  MenuScene.swift
//  Uno
//
//  Created by Andre Calfa on 3/10/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import SpriteKit
import AVFoundation

class MenuScene: SKScene {
	
	var playButton = SKSpriteNode()
	let playButtonTex = SKTexture(imageNamed: "start_button")
	var player : AVAudioPlayer?
	
	override func didMove(to view: SKView) {
		
		playButton = SKSpriteNode(texture: playButtonTex)
		playButton.position = CGPoint(x: frame.midX, y: frame.midY)
		self.addChild(playButton)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let pos = touch.location(in: self)
			let node = self.atPoint(pos)
			
			if node == playButton {
				if view != nil {
					playSound()
					let transition:SKTransition = SKTransition.fade(withDuration: 1)
					let scene:SKScene = GameScene(size: self.size)
					self.view?.presentScene(scene, transition: transition)
				}
			}
		}
	}
	
	func playSound() {
		let url = Bundle.main.url(forResource: "Button", withExtension: "wav")!
		
		do {
			player = try AVAudioPlayer(contentsOf: url)
			guard let player = player else { return }
			
			player.prepareToPlay()
			player.play()
		} catch let error {
			print(error.localizedDescription)
		}
	}
}
