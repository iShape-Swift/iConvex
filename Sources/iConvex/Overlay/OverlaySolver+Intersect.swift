//
//  OverlaySolver+Intersect.swift
//  
//
//  Created by Nail Sharipov on 22.05.2023.
//

import iFixFloat

public extension OverlaySolver {
    
    static func intersect(polyA a: [FixVec], polyB b: [FixVec]) -> Centroid {
        let pins = Self.find(polyA: a, polyB: b)
        return Self.intersect(polyA: a, polyB: b, pins: pins)
    }
    
    static func intersect(polyA a: [FixVec], polyB b: [FixVec], pins: [Pin]) -> Centroid {
        guard pins.count > 1 else {
            return .zero
        }
        
        var p0 = pins[pins.count - 1]
        for p1 in pins {
            
            
            
            p0 = p1
        }
        
        return .zero
    }
    
}


extension Array where Element == Pin {
    
    var findFirst: Pin {
        for p in self {
            switch p.type {
            case .empty, .into_empty, .out_empty: // can be removed
                continue
            default:
                return p
            }
        }
        
        return .zero
    }
    
    func findNext(current: Pin, last: Pin) -> Pin {
        let isInto = current.isEndInto
        var next = self.next(pin: current)
        while next.mA != last.mA {
            if isInto {
                let isOut = next.isEndOut
                if isOut {
                    return next
                }
            } else {
                let isInto = next.isEndInto
                if isInto {
                    return next
                }
            }
            next = self.next(pin: next)
        }
        
        return last
    }
    
}

extension Pin {
    
    var isEndInto: Bool {
        switch self.type {
        case .into, .empty_into, .out_into:
            return true
        default:
            return false
        }
    }

    var isEndOut: Bool {
        switch self.type {
        case .out, .empty_out, .into_out:
            return true
        default:
            return false
        }
    }
    
}
