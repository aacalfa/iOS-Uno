//
//  CardUtils.swift
//  Uno
//
//  Created by Andre Calfa on 3/5/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import Foundation

class CardUtils {
    private static var cardDeck = [Card?](repeating: nil, count:108)
    
    // Creates all 108 cards from Uno deck into an array of Cards
    static func loadDeck() {
        let redColor = CardColor.red
        let greenColor = CardColor.green
        let blueColor = CardColor.blue
        let yellowColor = CardColor.yellow
        let otherColor = CardColor.other
        var currIdx = 0
        
        // Load first half of deck, includes 0
        for color in [redColor, greenColor, blueColor, yellowColor] {
            for i in 0...12 {
                cardDeck[currIdx] = Card(cardColor: color, cardValue: i)
                currIdx += 1
            }
        }
        
        // Load second half of deck, excludes 0\
        for color in [redColor, greenColor, blueColor, yellowColor] {
            for i in 1...12 {
                var currVal = i
                if currVal == 13 {
                    currVal += 1
                }
                cardDeck[currIdx] = Card(cardColor: color, cardValue: currVal)
                currIdx += 1
            }
        }
        
        // Load wild cards
        for _ in 1...4 {
            cardDeck[currIdx] = Card(cardColor: otherColor, cardValue: SpecialVals.wild.rawValue)
            currIdx += 1
        }
        // Load wild cards PlusFour
        for _ in 1...4 {
            cardDeck[currIdx] = Card(cardColor: otherColor, cardValue: SpecialVals.wildPlusFour.rawValue)
            currIdx += 1
        }       
        
        // Load wild cards
        print("finished loadDeck\n")
    }

    // Return array of cards
    static func getCardDeck() -> [Card?] {
        return cardDeck
    }
    
    //
    static func shuffleDeck() {
        cardDeck.shuffle()
    }
    
}

// Helper methods that shuffle elements in an array. To be used with in shuffling the cards of the deck.

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
