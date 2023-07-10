//
//  Polygon+isConvex.swift
//  
//
//  Created by Nail Sharipov on 17.05.2023.
//

import iFixFloat
import iShape

public enum ConvexTest {
    case convex
    case nonConvex
    case degenerate
}

public extension FixPath {
    
    func convexCointains(_ point: FixVec) -> Bool {
        let p0 = self[0]
        let p1 = self[1]

        if Triangle.clockDirection(p0: p0, p1: p1, p2: point) < 0 {
            return false
        }

        var low = 1
        var high = count - 1

        while high - low > 1 {
            let mid = (low + high) >> 1
            let pm = self[mid]
            if Triangle.clockDirection(p0: p0, p1: pm, p2: point) < 0 {
                high = mid
            } else {
                low = mid
            }
        }

        return Triangle.isContain(p: point, p0: p0, p1: self[low], p2: self[high])
    }
    
    var isConvex: ConvexTest {
        var p0 = self[count - 2]
        var p1 = self[count - 1]

        var hasDegenerate = false
        
        for p2 in self {
            let result = Triangle.clockDirection(p0: p0, p1: p1, p2: p2)
            if result < 0 {
                return .nonConvex
            }
            
            hasDegenerate = hasDegenerate || result == 0
            
            p0 = p1
            p1 = p2
        }
        
        if hasDegenerate {
            return .degenerate
        }
        
        return .convex
    }
}
