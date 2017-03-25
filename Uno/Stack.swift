//
//  Stack.swift
//  Uno
//
//  Created by Andre Calfa on 3/4/17.
//  Copyright © 2017 Calfa. All rights reserved.
//

import Foundation

struct Stack<Element> {
    private var items = [Element]()
    
    
    /// Add item to stack
    ///
    /// - Parameter item: New item to be added
    mutating func push(_ item: Element) {
        items.append(item)
    }
    
    
    /// Get item last added to stack
    ///
    /// - Returns: Last added item
    mutating func pop() -> Element {
        return items.removeLast()
    }
    
    
    /// Check if stack is empty
    ///
    /// - Returns: True if stack is empty, false otherwise
    func isEmpty() -> Bool {
        return items.isEmpty
    }
    
    
    /// Inspect item last added to stack and does not remove it from stack
    ///
    /// - Returns: Last added item (is not removed from stack)
    func peek() -> Element {
        assert(!items.isEmpty)
        return items.last!
    }
    
    
    /// Get number of items in stack
    ///
    /// - Returns: Number of items in stack
    func count() -> Int {
        return items.count
    }
}
