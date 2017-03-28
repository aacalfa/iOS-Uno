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
    private var AIStatus: Bool

    /// Constructor
    ///
    /// - Parameters:
    ///   - cards: The initial set of cards of the player
    ///   - name: The name of the player (Default: "Anonymous")
    ///   - flagAI: Flag for artificial intelligence player (Default: false)
    init(cards: [Card?], name: String = "Anonymous", AIStatus: Bool = false) {
        self.cards = []
        
        for card in cards {
            self.cards.append(card)
        }
        
        self.name = name
        self.AIStatus = AIStatus
    }
    
    /// Copy constructor
    ///
    /// - Returns: New instance with the same data as the player
    func copy() -> Player {
        return Player(cards: self.cards)
    }
    
    /// Check if artificial intelligence (AI) player
    ///
    /// - Returns: The artificial intelligence (AI) status of the player
    func isAI() -> Bool {
        return self.AIStatus
    }
    
    /// Get cards
    ///
    /// - Returns: The set of cards of the player
    func getCards() -> [Card?] {
        return self.cards
    }
    
    /// Get points
    ///
    /// - Returns: The current points of the player
    func getPoints() -> Int {
        return self.points
    }
    
    /// Set points
    ///
    /// - Parameter points: The current points of the player
    func setPoints(points: Int) {
        self.points = points
    }
    
    /// Reset current points (i.e., set them to zero)
    func resetPoints() {
        self.points = 0
    }

    /// Get player's name
    ///
    /// - Returns: The name of the player
    func getName() -> String {
        return self.name
    }

    /// Set player's name
    ///
    /// - Parameter name: The name of the player
    func setName(name: String) {
        self.name = name
    }

    /// Play card by removing it from the player's set of cards
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
    
    /// Draw card by appending or inserting it into the player's set of cards
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

    /// Check if given card type is present in player's set of cards
    ///
    /// - Parameter cardType: Given card type
    /// - Returns: True if given card type is present in the set of cards, false otherwise
    func hasCardType(cardType: CardType) -> Bool {
        return self.cards.contains{$0?.cardType == cardType}
    }
    
    /// Check if given card color is present in player's set of cards
    ///
    /// - Parameter cardColor: Given card color
    /// - Returns: True if given card color is present in the set of cards, false otherwise
    func hasCardColor(cardColor: CardColor) -> Bool {
        return self.cards.contains{$0?.cardColor == cardColor}
    }

    /// Check if given card value is present in player's set of cards
    ///
    /// - Parameter cardValue: Given card value
    /// - Returns: True if given card value is present in the set of cards, false otherwise
    func hasCardValue(cardValue: Int) -> Bool {
        return self.cards.contains{$0?.cardValue == cardValue}
    }

    /// Check if given card is present in player's set of cards
    ///
    /// - Parameter card: Given card
    /// - Returns: True if given card is present in the set of cards, false otherwise
    func hasCard(card: Card) -> Bool {
        return self.hasCardType(cardType: card.cardType) && self.hasCardColor(cardColor: card.cardColor) && self.hasCardValue(cardValue: card.cardValue)
    }
    
    /// Check if given card object is present in player's set of cards
    ///
    /// - Parameter card: Given card
    /// - Returns: True if given card object is present in the set of cards (using object reference), false otherwise
    func hasCardObject(card: Card) -> Bool {
        return self.cards.contains{$0 === card}
    }
    
    
    /// Get card object that matches given card's type, color, and value
    ///
    /// - Parameter card: Card template sought
    /// - Returns: A card object if it exists, nil otherwise
    func getCard(card: Card) -> Card? {
        if self.hasCard(card: card) {
            return self.cards.filter{$0?.cardType == card.cardType && $0?.cardColor == card.cardColor && $0?.cardValue == card.cardValue}.first!
        }
        return nil
    }

    /// Get card with maximum value in player's set of cards
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

    /// Get card of a given color with maximum value in player's set of cards
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
    
    
    /// Get all cards of given color
    ///
    /// - Parameter cardColor: Given color
    /// - Returns: All cards of given color
    func getAllCardsColor(cardColor: CardColor) -> [Card] {
        var allCardsColor: [Card] = []
        
        for card in self.cards.filter({$0?.cardColor == cardColor}) {
            allCardsColor.append(card!)
        }
        
        return allCardsColor
    }
    
    
    /// Get number of cards of the given color
    ///
    /// - Returns: Number of cards of the given color
    func getCountByColor() -> [CardColor: Int] {
        // initialize values in dict
        var ret: [CardColor: Int] = [CardColor.red: 0,CardColor.green: 0, CardColor.blue: 0,
                                        CardColor.yellow: 0]
        for card in self.cards {
            // We don't want to account for wilds here
            if card?.cardColor == CardColor.other {
                continue
            }
            let curr = ret[card!.cardColor]
            ret[card!.cardColor] = curr! + 1
        }
        return ret
    }
    
    
    /// Get card color with most cards
    ///
    /// - Returns: Card color with most cards
    func getColorWithMostCards() -> CardColor {
        let dict = getCountByColor()
        var ret = CardColor.other
        var minValue = Int.min
        for (key, value) in dict {
            if value > minValue {
                minValue = value
                ret = key
            }
        }
        return ret
    }

    /// Converts the player information to `String`
    ///
    /// - Returns: A `String` representation of the player
    func toString() -> String {
        var playerString: String = ""
        
        for card in cards {
            playerString.append((card?.toString())! + "\n")
        }
        
        return playerString
    }
    
    /// Sets a new array of cards for player (FOR TEST PURPOSES ONLY)
    ///
    /// - Parameter cards: array of cards
    func setCards(cards: [Card]) {
        self.cards.removeAll()
        self.cards = cards
    }
}
