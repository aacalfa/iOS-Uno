//
//  Card.swift
//  Uno
//
//  Created by Andre Calfa on 3/4/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import SpriteKit

enum CardColor :Int {
    case red,
    green,
    blue,
    yellow,
    other
}

enum CardType :Int {
    case number,
    action,
    wild
}

enum SpecialVals :Int {
    case skip = 10,
    reverse,     // 11
    drawTwo,     // 12
    wild,        // 13
    wildDrawFour // 14
}

enum CardPropertyError :Error {
    case invalidColor
    case invalidValue
}

class Card : SKSpriteNode {
    let cardType :CardType
    let cardColor :CardColor
    let cardValue :Int
    let frontTexture :SKTexture
    let backTexture :SKTexture
    public override var description: String { get { return "<CardType = \(cardType)>, <CardColor = \(cardColor)>, <CardType = \(cardType)>, <CardValue = \(cardValue)>" } }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
 
    
    /// Constructor
    ///
    /// - Parameters:
    ///   - cardColor: Color for new card
    ///   - cardValue: Value for new card
    init(cardColor: CardColor, cardValue: Int) {
        self.cardColor = cardColor
        self.cardValue = cardValue
        
        // Check if input parameters are valid
        do {
            try Card.isValidCard(cardColor: cardColor, cardValue: cardValue)
        } catch CardPropertyError.invalidColor {
            print("invalid Card color")
        } catch CardPropertyError.invalidValue {
            print("invalid Card value")
        } catch {
            print("Unknown error when creating Card object")
        }
        
        // Figure out what CardType this card is
        if cardValue < SpecialVals.skip.rawValue {
            self.cardType = CardType.number
        } else if cardValue < SpecialVals.wild.rawValue {
            self.cardType = CardType.action
        } else {
            self.cardType = CardType.wild
        }
        
        // Load appropriate Card image
        switch cardColor {
        case .red:
            frontTexture = SKTexture(imageNamed: "Red_" + String(cardValue))
            break
        case .green:
            frontTexture = SKTexture(imageNamed: "Green_" + String(cardValue))
            break
        case .blue:
            frontTexture = SKTexture(imageNamed: "Blue_" + String(cardValue))
            break
        case .yellow:
            frontTexture = SKTexture(imageNamed: "Yellow_" + String(cardValue))
            break
        case .other:
            frontTexture = SKTexture(imageNamed: "Wild_" + String(cardValue))
            break
        }
        // Load back texture of card
        backTexture = SKTexture(imageNamed: "CardBack")
        
        super.init(texture: frontTexture, color: .clear, size: frontTexture.size())
    }
    
    
    /// Checks if given parameters are value for a card
    ///
    /// - Parameters:
    ///   - cardColor: Card color
    ///   - cardValue: Card value
    /// - Throws: <#throws value description#>
    static func isValidCard(cardColor: CardColor, cardValue: Int) throws {
        if cardValue < 0 || cardValue > SpecialVals.wildDrawFour.rawValue {
            throw CardPropertyError.invalidValue
        } else if cardValue < SpecialVals.wild.rawValue && cardColor == CardColor.other {
            throw CardPropertyError.invalidColor
        } else if cardValue >= SpecialVals.wild.rawValue && cardColor != CardColor.other {
            throw CardPropertyError.invalidColor
        }
    }
}
