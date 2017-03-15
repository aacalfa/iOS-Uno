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

class GameViewController: UIViewController {
	// State machine variables
	var menuState = Menu()
	var gamePlayState = GamePlay()
	var endGameState = EndGame()
	var stateMachine : GKStateMachine?
	
	var playersVec : [Player?] = [] // array that contains all players in the game
	var numOfPlayers : Int = 0 // determines how many players are participating in the game
	var menuScene : MenuScene? // store MenuScene object

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Load card deck
		_ = CardUtils.loadDeck()
		// Shuffle card deck
		CardUtils.shuffleDeck()
		
		// Create state machines
		createStateSm()
		
		// Present main menu
		menuScene = MenuScene(size: view.bounds.size)
		menuScene?.viewController = self
		let skView = view as! SKView
		skView.showsFPS = true
		skView.showsNodeCount = true
		skView.ignoresSiblingOrder = false // Draw background first, then cards
		menuScene?.scaleMode = .resizeFill
		skView.presentScene(menuScene)
	}
	
    override var prefersStatusBarHidden: Bool {
        return true
    }
	
	func createStateSm() {
		stateMachine = GKStateMachine(states: [menuState, gamePlayState, endGameState])
	}
	
	func initPlayers() {
		playersVec = [Player]()
		// TODO: get cards for each player
//		for i in 0...numOfPlayers - 1 {
//			playersVec[i] = Player(cards: nil, name: "Player" + String(i), flagAI: i == 0)
//		}
	}
}
