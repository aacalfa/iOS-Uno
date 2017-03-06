//
//  Stack.swift
//  Uno
//
//  Created by Andre Calfa on 3/4/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import Foundation

struct Stack<Element> {
	var items = [Element]()
	mutating func push(_ item: Element) {
		items.append(item)
	}
	mutating func pop() -> Element {
		return items.removeLast()
	}
}
