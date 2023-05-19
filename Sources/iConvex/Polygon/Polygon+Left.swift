//
//  Polygon+Convex.swift
//  
//
//  Created by Nail Sharipov on 16.05.2023.
//

import iFixFloat

// only for convex polygons !
public extension Array where Element == FixVec {

    var mostLeft: Int {
        let n = self.count
        let p1 = self[1].bitPack
        let p0 = self[0].bitPack
        if p1 > p0 {
            // search back
            var p = p0
            var i = 0
            var j = i.prev(n)
            var pi = self[j].bitPack
            while pi < p {
                p = pi
                i = j
                j = j.prev(n)
                pi = self[j].bitPack
            }
            return i
        } else {
            // search forward
            var p = p1
            var i = 1
            var j = i.next(n)
            var pi = self[j].bitPack
            while pi < p {
                p = pi
                i = j
                j = j.next(n)
                pi = self[j].bitPack
            }
            return i
        }
    }
    
    
    
}

