//
//  Convex+Edge.swift
//  
//
//  Created by Nail Sharipov on 20.05.2023.
//

import iFixFloat

// only for convex polygons !
extension Array where Element == FixVec {

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

    func edges(shapeId: Int, filter boundary: Boundary) -> [Edge] {
        
        let left = self.mostLeft
        let n = self.count
        
        // i will be direct index, j will be reverse index

        var edges = [Edge]()
        edges.reserveCapacity(n)
        
        var a0 = left
        var b0 = left
        
        var pA0 = self[a0]
        var pB0 = pA0

        repeat {
            if pA0.bitPack < pB0.bitPack {
                let a1 = a0.next(n)
                let pA1 = self[a1]
                if boundary.isIntersectionPossible(p0: pA0, p1: pA1) {
                    edges.append(.init(
                        shapeId: shapeId,
                        start: pA0,
                        end: pA1,
                        p0: .init(index: a0, point: pA0),
                        p1: .init(index: a1, point: pA1)
                    ))
                }
                pA0 = pA1
                a0 = a1
            } else {
                let b1 = b0.prev(n)
                let pB1 = self[b1]
                if boundary.isIntersectionPossible(p0: pB0, p1: pB1) {
                    edges.append(.init(
                        shapeId: shapeId,
                        start: pB0,
                        end: pB1,
                        p0: .init(index: b0, point: pB0),
                        p1: .init(index: b1, point: pB1)
                    ))
                }
                pB0 = pB1
                b0 = b1
            }
        } while a0 != b0
        
        return edges
    }
    
}

private extension Boundary {
 
    func isIntersectionPossible(p0: FixVec, p1: FixVec) -> Bool {
        // p1.x > p0.x sorted by it nature
        let eMinX = p0.x
        let eMaxX = p1.x
        
        let eMinY: Int64
        let eMaxY: Int64
        if p0.y > p1.y {
            eMinY = p1.y
            eMaxY = p0.y
        } else {
            eMinY = p0.y
            eMaxY = p1.y
        }
        
        let c0 = eMaxX < min.x
        let c1 = eMinX > max.x
        let c2 = eMaxY < min.y
        let c3 = eMinY > max.y
        
        return !(c0 || c1 || c2 || c3)
    }
    
}
