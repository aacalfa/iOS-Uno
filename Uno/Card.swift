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
	plusTwo,
	reverse,
	wild,
	wildPlusFour
}

class Card : SKSpriteNode {
	let cardType :CardType
	let cardColor :CardColor
	let cardValue :Int
	let frontTexture :SKTexture
	public override var description: String { get { return "<CardType = \(cardType)>, <CardColor = \(cardColor)>, <CardType = \(cardType)>, <CardValue = \(cardValue)>" } }
 
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}
 
	init(cardColor: CardColor, cardValue: Int) {
		self.cardColor = cardColor
		self.cardValue = cardValue
		
		// Figure out what CardType this card is
		if cardValue < SpecialVals.skip.rawValue {
			self.cardType = CardType.number
		} else if cardValue < SpecialVals.wild.rawValue {
			self.cardType = CardType.action
		} else {
			self.cardType = CardType.wild
		}
		
		// Load appropriate Card image. TODO: handle special cards and all colors
		switch cardColor {
		case .red:
			frontTexture = SKTexture(imageNamed: "Red_" + String(cardValue))
		default:
			frontTexture = SKTexture(image:#imageLiteral(resourceName: "Red_0"))

		}
		
		super.init(texture: frontTexture, color: .clear, size: frontTexture.size())
	}
}
