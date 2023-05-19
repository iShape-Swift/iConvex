//
//  Polygon+AreaMetric.swift
//  
//
//  Created by Nail Sharipov on 18.05.2023.
//

import iFixFloat

public extension Array where Element == FixVec {
    
    var area: FixFloat {
        let n = self.count
        var p0 = self[n - 1]

        var area: FixFloat = 0
        
        for p1 in self {
            let cross = p1.x * p0.y - p0.x * p1.y
            area += cross
            p0 = p1
        }
        
        return area >> (FixFloat.fractionBits + 1)
    }
}
