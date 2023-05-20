//
//  SwipeLineEvent.swift
//  
//
//  Created by Nail Sharipov on 20.05.2023.
//

@usableFromInline
struct SwipeLineEvent {

    static let empty = SwipeLineEvent(sortValue: -1, action: .add, edgeId: -1)
    
    enum Action: Int {
        case add = 1
        case remove = 0
    }

    @usableFromInline
    let sortValue: Int64
    let action: Action
    let edgeId: Int
    
}

// Binary search for reversed array
extension Array where Element == SwipeLineEvent {

    @inlinable
    /// Find index of first element equal original or first element bigger then original if no exact elements is present
    /// - Parameters:
    ///   - value: original element
    ///   - start: from where to start (mostly it's index of a)
    /// - Returns: index of lower boundary
    func lowerBoundary(value a: Int64, index: Int) -> Int {
        let last = count - 1
        var i = index
        if i > last {
            i = last
        } else if i < 0 {
            i = 0
        }
        var x = self[i].sortValue

        while i > 0 && x <= a  {
            i -= 1
            x = self[i].sortValue
        }
        
        while i < last && x > a  {
            i += 1
            x = self[i].sortValue
        }
        
        if x > a {
            i += 1
        }
        
        return i
    }
    
    @inlinable
    /// Find index of first element bigger then original
    /// - Parameters:
    ///   - value: original element
    ///   - start: from where to start (mostly it's index of a)
    /// - Returns: index of upper boundary
    func upperBoundary(value a: Int64, index: Int) -> Int {
        let last = count - 1
        var i = index
        if i > last {
            i = last
        } else if i < 0 {
            i = 0
        }
        var x = self[i].sortValue

        while i > 0 && x < a  {
            i -= 1
            x = self[i].sortValue
        }

        while i < last && x >= a  {
            i += 1
            x = self[i].sortValue
        }
        
        if x >= a {
            i += 1
        }
        
        return i
    }

    @inlinable
    /// Find index of element. If element is not found return index where it must be
    /// - Parameters:
    ///   - value: target element
    /// - Returns: index of element
    func findIndexAnyResult(value a: Int64) -> Int {
        var left = 0
        var right = count - 1

        var j = -1
        var i = (left + right) / 2
        var x = self[i].sortValue
        
        while i != j {
            if x < a {
                right = i - 1
            } else if x > a {
                left = i + 1
            } else {
                return i
            }
            
            j = i
            i = (left + right) / 2

            x = self[i].sortValue
        }
        
        if x > a {
            i = i + 1
        }

        return i
    }
}
