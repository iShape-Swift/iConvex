//
//  Polygon+Centroid.swift
//  
//
//  Created by Nail Sharipov on 23.05.2023.
//

import iFixFloat

public struct Centroid {
    public static let zero = Centroid(area: 0, center: .zero)
    public let area: FixFloat
    public let center: FixVec
}

public extension Array where Element == FixVec {
    
    var centroid: Centroid {
        var center = FixVec.zero
        var area: Int64 = 0

        var j = self.count - 1
        var p0 = self[j]

        for i in 0..<self.count {
            let p1 = self[i]
            let e = p1 - p0

            let crossProduct = p1.crossProduct(p0)
            area += crossProduct

            let sp = p0 + p1
            center = center + sp * crossProduct

            p0 = p1
            j = i
        }

        area >>= 1
        let s = 6 * area

        let x = center.x.div(s)
        let y = center.y.div(s)
        
        return Centroid(area: area, center: center)
    }
    
}
