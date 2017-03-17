//
//  Player.swift
//  Uno
//
//  Created by Bruno Abreu Calfa on 3/8/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import Foundation

class Player {
    
    private var cards: [Card?]
    private var points: Int = 0
    private var name: String
    private var flagAI: Bool

    /**
     Constructor.
     
     - parameters:
        - cards: The initial set of cards of the player
        - name: The name of the player (Default: "Anonymous")
        - isAI: Flag for artificial intelligence player (Default: false)
    */
    init(cards: [Card?], name: String = "Anonymous", flagAI: Bool = false) {
        self.cards = []
        
        for card in cards {
            self.cards.append(card)
        }
        
        self.name = name
        self.flagAI = flagAI
    }
    
    /**
     Copy constructor.
     
     - returns: New instance with the same data as the player
     */
    func copy() -> Player {
        return Player(cards: self.cards)
    }
    
    /**
     Checks if artificial intelligence (AI) player.
     
     - returns: The artificial intelligence (AI) status of the player
     */
    func isAI() -> Bool {
        return self.flagAI
    }
    
    /**
     Gets cards.
     
     - returns: The set of cards of the player
     */
    func getCards() -> [Card?] {
        return self.cards
    }
    
    /**
     Gets points.
     
     - returns: The current points of the player
     */
    func getPoints() -> Int {
        return self.points
    }
    
    /**
     Sets points.
     
     - parameter points: The current points of the player
     */
    func setPoints(points: Int) {
        self.points = points
    }
    
    /**
     Resets current points (i.e., set them to zero).
     */
    func resetPoints() {
        self.points = 0
    }
    
    /**
     Gets player's name.
     
     - returns: The name of the player
     */
    func getName() -> String {
        return self.name
    }
    
    /**
     Sets player's name.
     
     - parameter name: The name of the player
     */
    func setName(name: String) {
        self.name = name
    }
    
    /**
     Plays card by removing it from the player's set of cards.
     
     - parameter card: The played card
     */
    func playCard(card: Card) {
        if self.cards.count > 0 {
            // First, check if card exists, then remove it if it does
            let ind = self.cards.index{$0 === card}
            if ind != nil {
                self.cards.remove(at: ind!)
            }
        }
    }
    
    /**
     Draws card by appending or inserting it into the player's set of cards.
     
     - parameter card: The drawn card
     */
    func drawCard(card: Card) {
        // First, check if card exists, then append it if it doesn't or insert it if it does
        let ind = self.cards.index{$0 === card}
        if ind == nil {
            self.cards.append(card)
        } else {
            self.cards.insert(card, at: ind!)
        }
    }
    
    /**
     Checks if given card type is present in player's set of cards.
     
     - parameter cardType: Given card type
     - returns: True if given card type is present in the set of cards, false otherwise 
    */
    func hasCardType(cardType: CardType) -> Bool {
        for card in self.cards {
            if card?.cardType == cardType {
                return true
            }
        }
        return false
    }
    
    /**
     Checks if given card color is present in player's set of cards.
     
     - parameter cardColor: Given card color
     - returns: True if given card color is present in the set of cards, false otherwise
     */
    func hasCardColor(cardColor: CardColor) -> Bool {
        for card in self.cards {
            if card?.cardColor == cardColor {
                return true
            }
        }
        return false
    }
    
    /**
     Checks if given card value is present in player's set of cards.
     
     - parameter cardValue: Given card value
     - returns: True if given card value is present in the set of cards, false otherwise
     */
    func hasCardValue(cardValue: Int) -> Bool {
        for card in self.cards {
            if card?.cardValue == cardValue {
                return true
            }
        }
        return false
    }
    
    /**
     Checks if given card is present in player's set of cards.
     
     - parameter card: Given card
     - returns: True if given card is present in the set of cards, false otherwise
     */
    func hasCard(card: Card) -> Bool {
        return self.hasCardType(cardType: card.cardType) && self.hasCardColor(cardColor: card.cardColor) && self.hasCardValue(cardValue: card.cardValue)
    }
    
    /**
     Gets card with maximum value in player's set of cards.
     
     - parameter excludeWildDrawFourCard: Flag to exclude or not the Wild Draw Four card
     - returns: Card with maximum value, or nil if set of cards is empty
     */
    func getMaximumValueCard(excludeWildDrawFourCard: Bool = true) -> Card? {
        if excludeWildDrawFourCard {
            return self.cards.filter{$0 != CardUtils.wildDrawFourCard}.max{ a, b in (a?.cardValue)! < (b?.cardValue)! }!
        } else {
            return self.cards.max{ a, b in (a?.cardValue)! < (b?.cardValue)! }!
        }
    }
    
    /**
     Gets card of a given color with maximum value in player's set of cards.
     
     - parameter cardColor: The color of the card
     - returns: Card with maximum value, or nil if set of cards is empty
     */
    func getMaximumValueCard(cardColor: CardColor) -> Card? {
        return self.cards.filter{$0?.cardColor == cardColor}.max{a, b in (a?.cardValue)! < (b?.cardValue)!}!
    }
    
    /**
     Converts the player information to `String`.
     
     - returns: A `String` representation of the player
     */
    func toString() -> String {
        var playerString: String = ""
        
        for card in cards {
            playerString.append("CardColor: " + String(describing: card?.cardColor.hashValue) + "\tCardType: " + String(describing: card?.cardType.hashValue) + "\tCardValue: " + String(describing: card?.cardValue.hashValue) + "\n")
        }
        
        return playerString
    }
}
