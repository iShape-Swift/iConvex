//
//  CrossSolver+Brute.swift
//  
//
//  Created by Nail Sharipov on 10.07.2023.
//

import iFixFloat
import iShape

extension CrossSolver {
    
    static func bruteIntersect(pathA: [FixVec], pathB: [FixVec], bndA: FixBnd, bndB: FixBnd) -> [Pin] {
        let listB = pathB.edges(filter: bndA)
        
        var pins = [Pin]()

        var i0 = pathA.count - 1
        var a0 = pathA[i0]
        var i1 = 0
        for a1 in pathA {
            let bd = FixBnd(p0: a0, p1: a1)
            if bd.isCollide(bndB) {
                let eA = Edge(p0: IndexPoint(index: i0, point: a0), p1: IndexPoint(index: i1, point: a1), bd: bd)
                for eB in listB {
                    let result = eA.cross(eB)
                    if result.isCross {
                        pins.append(result.pin)
                    }
                }
            }
            
            a0 = a1
            i0 = i1
            i1 += 1
        }
     
        guard pins.count > 1 else {
            return pins
        }
        
        pins.sort(by: { $0.mA < $1.mA })
        
        var result = [Pin]()
        var p0 = pins[0]
        result.append(p0)
        for i in 1..<pins.count {
            let pi = pins[i]
            if p0.mA != pi.mA {
                result.append(Pin(i: result.count, pin: pi))
            }
            p0 = pi
        }
        
        return result
    }
   
}

private struct Edge {

    struct CrossResult {
        let isCross: Bool
        let pin: Pin
    }

    let p0: IndexPoint
    let p1: IndexPoint
    let bd: FixBnd

    func cross(_ other: Edge) -> CrossResult {
        guard self.bd.isCollide(other.bd) else {
            return .init(isCross: false, pin: .zero)
        }
        
        guard let cross = EdgeCrosser.cross(a0: p0.point, a1: p1.point, b0: other.p0.point, b1: other.p1.point) else {
            return CrossResult(isCross: false, pin: .zero)
        }
        
        switch cross.type {
        case .pure:
            let mA = MileStone(index: p0.index, offset: cross.point.sqrDistance(p0.point))
            let mB = MileStone(index: other.p0.index, offset: cross.point.sqrDistance(other.p0.point))

            return CrossResult(isCross: true, pin: Pin(p: cross.point, mA: mA, mB: mB))
        case .end_a:
            let mA = MileStone(index: cross.point == p0.point ? p0.index : p1.index)
            let mB = MileStone(index: other.p0.index, offset: cross.point.sqrDistance(other.p0.point))
            
            return CrossResult(isCross: true, pin: Pin(p: cross.point, mA: mA, mB: mB))
        case .end_b:
            let mA = MileStone(index: p0.index, offset: cross.point.sqrDistance(p0.point))
            let mB = MileStone(index: cross.point == other.p0.point ? other.p0.index : other.p1.index)
            
            return CrossResult(isCross: true, pin: Pin(p: cross.point, mA: mA, mB: mB))
        case .common_end:
            let mA = MileStone(index: cross.point == p0.point ? p0.index : p1.index)
            let mB = MileStone(index: cross.point == other.p0.point ? other.p0.index : other.p1.index)
            
            return CrossResult(isCross: true, pin: Pin(p: cross.point, mA: mA, mB: mB))
        }
    }
}

 
private extension Array where Element == FixVec {
    
    func edges(filter: FixBnd) -> [Edge] {
        var edges = [Edge]()
        edges.reserveCapacity(count)
        
        var i0 = count - 1
        var i1 = 0
        var a0 = self[i0]
        for a1 in self {
            let bd = FixBnd(p0: a0, p1: a1)
            if bd.isCollide(filter) {
                edges.append(Edge(p0: IndexPoint(index: i0, point: a0), p1: IndexPoint(index: i1, point: a1), bd: bd))
            }
            a0 = a1
            i0 = i1
            i1 += 1
        }
        
        return edges
    }
    
}
