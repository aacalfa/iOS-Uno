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
    let cardType: CardType
    var cardColor: CardColor
    let cardValue: Int
    let frontTexture: SKTexture
    let backTexture: SKTexture
    let cardPoints: Int
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
            self.cardPoints = cardValue
        } else if cardValue < SpecialVals.wild.rawValue {
            self.cardType = CardType.action
            self.cardPoints = 20
        } else {
            self.cardType = CardType.wild
            self.cardPoints = 50
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
    
    
    /// Return card color as a string
    ///
    /// - Returns: string informing card color
    func colorAsString() -> String {
        switch self.cardColor {
        case .red:
            return "Red"
        case .green:
            return "Green"
        case .blue:
            return "Blue"
        case .yellow:
            return "Yellow"
        default:
            return "other"
        }
        
    }
    
    
    /// Return card color as UIColor
    ///
    /// - Returns: UIColor value related to card color
    func colorAsUIColor() -> UIColor {
        switch self.cardColor {
        case .red:
            return UIColor.red
        case .green:
            return UIColor.green
        case .blue:
            return UIColor.cyan
        case .yellow:
            return UIColor.yellow
        default:
            return UIColor.black
        }
    }
    
    
    /// Checks if given parameters are value for a card
    ///
    /// - Parameters:
    ///   - cardColor: Card color
    ///   - cardValue: Card value
    /// - Throws: Value exception
    static func isValidCard(cardColor: CardColor, cardValue: Int) throws {
        if cardValue < 0 || cardValue > SpecialVals.wildDrawFour.rawValue {
            throw CardPropertyError.invalidValue
        } else if cardValue < SpecialVals.wild.rawValue && cardColor == CardColor.other {
            throw CardPropertyError.invalidColor
        } else if cardValue >= SpecialVals.wild.rawValue && cardColor != CardColor.other {
            throw CardPropertyError.invalidColor
        }
    }
	
	
	/// Retunrs CardColor value given a color in String
	///
	/// - Parameter color: card color represented as string
	/// - Returns: card color represented as CardColor
	static func stringToCardColor(color: String) -> CardColor {
		switch color {
		case "Red":
			return CardColor.red
		case "Green":
			return CardColor.green
		case "Blue":
			return CardColor.blue
		case "Yellow":
			return CardColor.yellow
		default:
			return CardColor.other
		}
	}
	
	
    /// Returns a string representation of the card
    ///
    /// - Returns: String representation of the card
    func toString() -> String {
        return "CardType: " + String(describing: cardType) + "\tCardColor: " + String(describing: cardColor) + "\tCardValue: " + String(describing: cardValue)
    }
}
