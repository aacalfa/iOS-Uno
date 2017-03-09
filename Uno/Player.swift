//
//  Player.swift
//  Uno
//
//  Created by Bruno Abreu Calfa on 3/8/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import Foundation

class Player {
    
    var cards: [Card?]

    init(cards: [Card?]) {
        self.cards = []
        
        for card in cards {
            self.cards.append(card)
        }
    }
    
    func getCards() -> [Card?] {
        return self.cards
    }
    
    func playCard(card: Card) {
        self.cards.remove(at: self.cards.index{$0 === card}!)
    }
    
    func drawCard(card: Card) {
        self.cards.append(card)
    }
    
    func toString() -> String {
        var playerString: String = ""
        
        for card in cards {
            playerString.append("CardColor: " + String(describing: card?.cardColor) + "\tCardType: " + String(describing: card?.cardType) + "\tCardValue: " + String(describing: card?.cardValue) + "\n")
        }
        
        return playerString
    }
}
