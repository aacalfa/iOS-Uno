//
//  GameSm.swift
//  Uno
//
//  Created by Andre Calfa on 3/7/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import Foundation
import GameKit

// Represents main menu
class Menu: GKState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is GamePlay.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        print("Entered main menu")
    }
}

// Represents in-game scenario
class GamePlay: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is EndGame.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        print("Uno game has started")
    }
    
}

// Handle game over
class EndGame: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is Menu.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        print("Game is over")
    }
}
