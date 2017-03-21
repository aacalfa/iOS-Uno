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

    /// Constructor
    ///
    /// - Parameters:
    ///   - cards: The initial set of cards of the player
    ///   - name: The name of the player (Default: "Anonymous")
    ///   - flagAI: Flag for artificial intelligence player (Default: false)
    init(cards: [Card?], name: String = "Anonymous", flagAI: Bool = false) {
        self.cards = []
        
        for card in cards {
            self.cards.append(card)
        }
        
        self.name = name
        self.flagAI = flagAI
    }
    
    /// Copy constructor.
    ///
    /// - Returns: New instance with the same data as the player
    func copy() -> Player {
        return Player(cards: self.cards)
    }
    
    /// Checks if artificial intelligence (AI) player.
    ///
    /// - Returns: The artificial intelligence (AI) status of the player
    func isAI() -> Bool {
        return self.flagAI
    }
    
    /// Gets cards.
    ///
    /// - Returns: The set of cards of the player
    func getCards() -> [Card?] {
        return self.cards
    }
    
    /// Gets points.
    ///
    /// - Returns: The current points of the player
    func getPoints() -> Int {
        return self.points
    }
    
    /// Sets points.
    ///
    /// - Parameter points: The current points of the player
    func setPoints(points: Int) {
        self.points = points
    }
    
    /// Resets current points (i.e., set them to zero).
    func resetPoints() {
        self.points = 0
    }

    /// Gets player's name.
    ///
    /// - Returns: The name of the player
    func getName() -> String {
        return self.name
    }

    /// Sets player's name.
    ///
    /// - Parameter name: The name of the player
    func setName(name: String) {
        self.name = name
    }

    /// Plays card by removing it from the player's set of cards.
    ///
    /// - Parameter card: The played card
    func playCard(card: Card) {
        if self.cards.count > 0 {
            // First, check if card exists, then remove it if it does
            let ind = self.cards.index{$0 === card}
            if ind != nil {
                self.cards.remove(at: ind!)
            }
        }
    }
    
    /// Draws card by appending or inserting it into the player's set of cards.
    ///
    /// - Parameter card: The drawn card
    func drawCard(card: Card) {
        // First, check if card exists, then append it if it doesn't or insert it if it does
        let ind = self.cards.index{$0 === card}
        if ind == nil {
            self.cards.append(card)
        } else {
            self.cards.insert(card, at: ind!)
        }
    }

    /// Checks if given card type is present in player's set of cards.
    ///
    /// - Parameter cardType: Given card type
    /// - Returns: True if given card type is present in the set of cards, false otherwise
    func hasCardType(cardType: CardType) -> Bool {
        return self.cards.contains{$0?.cardType == cardType}
    }
    
    /// Checks if given card color is present in player's set of cards.
    ///
    /// - Parameter cardColor: Given card color
    /// - Returns: True if given card color is present in the set of cards, false otherwise
    func hasCardColor(cardColor: CardColor) -> Bool {
        return self.cards.contains{$0?.cardColor == cardColor}
    }

    /// Checks if given card value is present in player's set of cards.
    ///
    /// - Parameter cardValue: Given card value
    /// - Returns: True if given card value is present in the set of cards, false otherwise
    func hasCardValue(cardValue: Int) -> Bool {
        return self.cards.contains{$0?.cardValue == cardValue}
    }

    /// Checks if given card is present in player's set of cards.
    ///
    /// - Parameter card: Given card
    /// - Returns: True if given card is present in the set of cards, false otherwise
    func hasCard(card: Card) -> Bool {
        return self.hasCardType(cardType: card.cardType) && self.hasCardColor(cardColor: card.cardColor) && self.hasCardValue(cardValue: card.cardValue)
    }
    
    /// Checks if given card object is present in player's set of cards.
    ///
    /// - Parameter card: Given card
    /// - Returns: True if given card object is present in the set of cards (using object reference), false otherwise
    func hasCardObject(card: Card) -> Bool {
        return self.cards.contains{$0 === card}
    }
    
    
    /// Get card object that matches given card's type, color, and value.
    ///
    /// - Parameter card: Card template sought
    /// - Returns: A card object if it exists, nil otherwise
    func getCard(card: Card) -> Card? {
        if self.hasCard(card: card) {
            return self.cards.filter{$0?.cardType == card.cardType && $0?.cardColor == card.cardColor && $0?.cardValue == card.cardValue}.first!
        }
        return nil
    }

    /// Gets card with maximum value in player's set of cards.
    ///
    /// - Parameter excludeWildDrawFourCard: Flag to exclude or not the Wild Draw Four card
    /// - Returns: Card with maximum value, or nil if set of cards is empty
    func getMaximumValueCard(excludeWildDrawFourCard: Bool = true) -> Card? {
        if excludeWildDrawFourCard {
            return self.cards.filter{$0?.cardValue != CardUtils.wildDrawFourCard.cardValue}.max{ a, b in (a?.cardValue)! < (b?.cardValue)! }!
        } else {
            return self.cards.max{ a, b in (a?.cardValue)! < (b?.cardValue)! }!
        }
    }

    /// Gets card of a given color with maximum value in player's set of cards.
    ///
    /// - Parameter cardColor: The color of the card
    /// - Returns: Card with maximum value, or nil if set of cards is empty
    func getMaximumValueCard(cardColor: CardColor) -> Card? {
        if self.cards.contains(where: {$0?.cardColor == cardColor}) {
            return self.cards.filter{$0?.cardColor == cardColor}.max{a, b in (a?.cardValue)! < (b?.cardValue)!}!
        } else {
            return nil
        }
    }

    /// Converts the player information to `String`.
    ///
    /// - Returns: A `String` representation of the player
    func toString() -> String {
        var playerString: String = ""
        
        for card in cards {
            playerString.append((card?.toString())! + "\n")
        }
        
        return playerString
    }
}
