//
//  IntersectSolver.swift
//  
//
//  Created by Nail Sharipov on 17.05.2023.
//

import iFixFloat

public struct PinNode {

    public let point: FixVec
    public let stoneA: MileStone
    public let stoneB: MileStone
    public let area: FixFloat
}

private struct PointStone {
    let m: MileStone
    let p: FixVec
}

private extension PinDot {

    var a: PointStone {
        .init(m: mA, p: p)
    }

    var b: PointStone {
        .init(m: mB, p: p)
    }
}


public struct IntersectSolver {
    
    public func intersect(a: [FixVec], b: [FixVec]) {
        let dots = CrossSolver.intersect(a: a, b: b).pins
        
        var j = dots.count - 1
        var d0 = dots[j]
        for i in 0..<dots.count {
            let di = dots[i]
            //
            //            let area = Self.areaBetween(start: d0.p, end: di.p, a: a, b: b, m0: d0.mB, m1: di.mB)
            //
            //            let b0 = d0.mB.offset == 0 ? d0.mB.index.next(nB) : d0.mB.index
            //            let b1 = di.mB.offset == 0 ? di.mB.index.prev(nB) : di.mB.index
            //
            //
            d0 = di
            j = i
        }
    }

    private static func directArea(s0: PointStone, s1: PointStone, points: [FixVec]) -> FixFloat {
        guard s0.m != s1.m else {
            return 0
        }

        var area: FixFloat = 0
        var p0 = s0.p

        if s0.m < s1.m {
            // example from 3 to 6

            var i = s0.m.index + 1
            
            let last = s1.m.offset == 0 ? s1.m.index : s1.m.index + 1
            
            while i < last {
                let p1 = points[i]
                area += p0.directCrossProduct(p1)
                p0 = p1
                i += 1
            }
        } else {
            // example from 5 to 2
            var i = s0.m.index + 1
            
            while i < points.count {
                let p1 = points[i]
                area += p0.directCrossProduct(p1)
                p0 = p1
                i += 1
            }

            i = 0
            let last = s1.m.offset == 0 ? s1.m.index : s1.m.index + 1
            
            while i < last {
                let p1 = points[i]
                area += p0.directCrossProduct(p1)
                p0 = p1
                i += 1
            }
        }
        
        area += p0.directCrossProduct(s1.p)
        
        return area >> (FixFloat.fractionBits + 1)
    }
    
}

private extension FixVec {
    
    @inline(__always)
    func directCrossProduct(_ v: FixVec) -> FixFloat {
        v.x * y - x * v.y
    }
}


#if DEBUG

public extension IntersectSolver {
    
    static func debugIntersect(a: [FixVec], b: [FixVec]) -> [ABResult] {
        var result: [ABResult] = []
        let pinMap = CrossSolver.intersect(a: a, b: b)

        guard !pinMap.isEmpty else { return [] }
        
        for i in 0..<pinMap.pins.count {
            let pin0 = pinMap.pins[i]
            let pin1 = pinMap.nextA(pin: pin0)
            
            let aPath = Self.directPoints(s0: pin0.dot.a, s1: pin1.dot.a, points: a)
            let bPath = Self.directPoints(s0: pin0.dot.b, s1: pin1.dot.b, points: b)
            
            let aSet = Set(aPath)
            assert(aSet.count == aPath.count)
            let bSet = Set(bPath)
            assert(bSet.count == bPath.count)

            let aArea = Self.directArea(s0: pin0.dot.a, s1: pin1.dot.a, points: a)
            let bArea = Self.directArea(s0: pin0.dot.b, s1: pin1.dot.b, points: b)
            
            let area = aArea - bArea
            
            result.append(ABResult(a: aPath, b: bPath, area: area))
        }
        
        return result
    }
    
    
    private static func directPoints(s0: PointStone, s1: PointStone, points: [FixVec]) -> [FixVec] {
        guard s0.m != s1.m else {
            return []
        }

        var area: [FixVec] = []

        area.append(s0.p)

        if s0.m < s1.m {
            // example from 3 to 6

            var i = s0.m.index + 1
            
            let last = s1.m.offset == 0 ? s1.m.index : s1.m.index + 1
            
            while i < last {
                area.append(points[i])
                i += 1
            }
        } else {
            // example from 5 to 2
            var i = s0.m.index + 1
            
            while i < points.count {
                area.append(points[i])
                i += 1
            }

            i = 0
            let last = s1.m.offset == 0 ? s1.m.index : s1.m.index + 1
            
            while i < last {
                area.append(points[i])
                i += 1
            }
        }
        
        area.append(s1.p)
        
        return area
    }
    
}

public struct ABResult {
    public let a: [FixVec]
    public let b: [FixVec]
    public let area: FixFloat
}
   
    
#endif
