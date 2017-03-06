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
	
	static func loadDeck() {
		let redColor = CardColor.red
		let greenColor = CardColor.green
		let blueColor = CardColor.blue
		let yellowColor = CardColor.yellow
		var currIdx = 0
		
		// Load first half of deck, includes 0 and wild card
		for color in [redColor, greenColor, blueColor, yellowColor] {
			for i in 0...13 {
				cardDeck[currIdx] = Card(cardColor: color, cardValue: i)
				currIdx += 1
			}
		}
		
		// Load second half of deck, excludes 0 and has wild card plus 4 card
		for color in [redColor, greenColor, blueColor, yellowColor] {
			for i in 1...13 {
				var currVal = i
				if currVal == 13 {
					currVal += 1
				}
				cardDeck[currIdx] = Card(cardColor: color, cardValue: currVal)
				currIdx += 1
			}
		}
		print("finished loadDeck\n")
	}
	
	static func getCardDeck() -> [Card?] {
		return cardDeck
	}
}
