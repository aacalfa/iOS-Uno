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
        if self.cards.count > 0 {
            // First, check if card exists, then remove it if it does
            let ind = self.cards.index{$0 === card}
            if ind != nil {
                self.cards.remove(at: ind!)
            }
        }
    }
    
    func drawCard(card: Card) {
        // First, check if card exists, then append it if it doesn't or insert it if it does
        let ind = self.cards.index{$0 === card}
        if ind == nil {
            self.cards.append(card)
        } else {
            self.cards.insert(card, at: ind!)
        }
    }
    
    func toString() -> String {
        var playerString: String = ""
        
        for card in cards {
            playerString.append("CardColor: " + String(describing: card?.cardColor.hashValue) + "\tCardType: " + String(describing: card?.cardType.hashValue) + "\tCardValue: " + String(describing: card?.cardValue.hashValue) + "\n")
        }
        
        return playerString
    }
    
    func copy() -> Player {
        return Player(cards: self.cards)
    }
}
