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

        var p0 = self[count - 1]

        for p1 in self {
            let crossProduct = p1.unsafeCrossProduct(p0)
            area += crossProduct

            let sp = p0 + p1
            center = center + sp.unsafeMul(crossProduct)

            p0 = p1
        }

        let s = 3 * area

        let x = center.x / s
        let y = center.y / s
        
        area = area >> (1 + FixFloat.fractionBits)
        
        return Centroid(area: area, center: FixVec(x, y))
    }
    
}
