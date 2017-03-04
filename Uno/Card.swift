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
	yellow,
	green,
	blue,
	other
}

enum CardType :Int {
	case number,
	action,
	wild
}

enum SpecialVals :Int {
	case Skip = 10,
	plusTwo,
	reverse,
	wild,
	wildPlusFour
}

class Card : SKSpriteNode {
	let cardType :CardType
	let cardColor :CardColor
	let frontTexture :SKTexture
 
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}
 
	init(cardType: CardType, cardColor: CardColor, cardValue: Int) {
		self.cardType = cardType
		self.cardColor = cardColor
		
		switch cardColor {
		case .red:
			frontTexture = SKTexture(imageNamed: "Red_" + String(cardValue))
		default:
			frontTexture = SKTexture(image:#imageLiteral(resourceName: "Red_0"))

		}
		
		super.init(texture: frontTexture, color: .clear, size: frontTexture.size())
	}
}
