//
//  CrossSolver+Convex.swift
//  
//
//  Created by Nail Sharipov on 16.05.2023.
//

import iFixFloat

public struct CrossSolver {

    public static func intersect(a: [FixVec], b: [FixVec]) -> PinMap {
        let aBnd = Boundary(points: a)
        let bBnd = Boundary(points: b)
        return self.intersect(a: a, b: b, aBnd: aBnd, bBnd: bBnd)
    }
    
    public static func intersect(a: [FixVec], b: [FixVec], aBnd: Boundary, bBnd: Boundary) -> PinMap {
        let edAs = a.sortedEdges(filter: bBnd)
        let edBs = b.sortedEdges(filter: aBnd)
        
        guard !edAs.isEmpty && !edBs.isEmpty else {
            return PinMap()
        }

        var i0 = 0
        var dotMap = [Int64: PinDot]()
        dotMap.reserveCapacity(4)

        for edB in edBs {
            
            var i = i0
            while i < edAs.count {
                let edA = edAs[i]
                
                if edB.segment.a.bitPack > edA.segment.b.bitPack {
                    i0 += 1
                } else {
                    let cross = edA.segment.cross(edB.segment)
                    switch cross.type {
                    case .not_cross, .same_line:
                        break
                    case .pure:
                        let mA = edA.mileStone(point: cross.point)
                        let mB = edB.mileStone(point: cross.point)
                        dotMap[cross.point.bitPack] = PinDot(p: cross.point, mA: mA, mB: mB)
                    case .end_a0:
                        let mA = edA.mileStone0()
                        let mB = edB.mileStone(point: cross.point)
                        dotMap[cross.point.bitPack] = PinDot(p: cross.point, mA: mA, mB: mB)
                    case .end_a1:
                        let mA = edA.mileStone1()
                        let mB = edB.mileStone(point: cross.point)
                        dotMap[cross.point.bitPack] = PinDot(p: cross.point, mA: mA, mB: mB)
                    case .end_b0:
                        let mA = edA.mileStone(point: cross.point)
                        let mB = edB.mileStone0()
                        dotMap[cross.point.bitPack] = PinDot(p: cross.point, mA: mA, mB: mB)
                    case .end_b1:
                        let mA = edA.mileStone(point: cross.point)
                        let mB = edB.mileStone1()
                        dotMap[cross.point.bitPack] = PinDot(p: cross.point, mA: mA, mB: mB)
                    case .end_a0_b0:
                        let mA = edA.mileStone0()
                        let mB = edB.mileStone0()
                        dotMap[cross.point.bitPack] = PinDot(p: cross.point, mA: mA, mB: mB)
                    case .end_a0_b1:
                        let mA = edA.mileStone0()
                        let mB = edB.mileStone1()
                        dotMap[cross.point.bitPack] = PinDot(p: cross.point, mA: mA, mB: mB)
                    case .end_a1_b0:
                        let mA = edA.mileStone1()
                        let mB = edB.mileStone0()
                        dotMap[cross.point.bitPack] = PinDot(p: cross.point, mA: mA, mB: mB)
                    case .end_a1_b1:
                        let mA = edA.mileStone1()
                        let mB = edB.mileStone1()
                        dotMap[cross.point.bitPack] = PinDot(p: cross.point, mA: mA, mB: mB)
                    }
                }
                i += 1
            }
        }

        return PinMap(dots: Array(dotMap.values))
    }

}

private struct Edge {
    let segment: XSortedSegment
    let a: Int
    let b: Int
    let isDirect: Bool
    
    func mileStone(point: FixVec) -> MileStone {
        if isDirect {
            let offset = segment.a.sqrDistance(point)
            return MileStone(index: a, offset: offset)
        } else {
            let offset = segment.b.sqrDistance(point)
            return MileStone(index: b, offset: offset)
        }
    }
    
    func mileStone0() -> MileStone {
        MileStone(index: a)
    }

    func mileStone1() -> MileStone {
        MileStone(index: b)
    }

}

private extension Array where Element == FixVec {
    
    func sortedEdges(filter boundary: Boundary) -> [Edge] {
        let left = self.mostLeft
        let n = self.count
        
        // i will be direct index, j will be reverse index

        var edges = [Edge]()
        edges.reserveCapacity(n / 2)
        
        var i0 = left
        var j0 = left
        
        var pi0 = self[i0]
        var pj0 = pi0

        var i1 = i0.next(n)
        var j1 = j0.prev(n)

        var pi1 = self[i1]
        var pj1 = self[j1]

        var iBit = pi1.bitPack
        var jBit = pj1.bitPack
        
        while iBit != jBit {
            let edge: Edge

            if iBit < jBit {
                edge = Edge(segment: .init(a: pi0, b: pi1), a: i0, b: i1, isDirect: true)

                i0 = i1
                pi0 = pi1
                
                i1 = i1.next(n)
                pi1 = self[i1]
                iBit = pi1.bitPack
            } else {
                edge = Edge(segment: .init(a: pj0, b: pj1), a: j0, b: j1, isDirect: false)

                j0 = j1
                pj0 = pj1
                
                j1 = j1.prev(n)
                pj1 = self[j1]
                jBit = pj1.bitPack
            }
            
            if boundary.isIntersectionPossible(segment: edge.segment) {
                edges.append(edge)
            }
        }
        
        let iEdge = Edge(segment: .init(a: pi0, b: pi1), a: i0, b: i1, isDirect: true)
        let jEdge = Edge(segment: .init(a: pj0, b: pj1), a: j0, b: j1, isDirect: false)
        
        if pi0.bitPack < pj0.bitPack {
            if boundary.isIntersectionPossible(segment: iEdge.segment) {
                edges.append(iEdge)
            }
            if boundary.isIntersectionPossible(segment: jEdge.segment) {
                edges.append(jEdge)
            }
        } else {
            if boundary.isIntersectionPossible(segment: jEdge.segment) {
                edges.append(jEdge)
            }
            if boundary.isIntersectionPossible(segment: iEdge.segment) {
                edges.append(iEdge)
            }
        }

        return edges
    }
}


private extension Boundary {
 
    func isIntersectionPossible(segment s: XSortedSegment) -> Bool {
        // p1.x > p0.x sorted by it nature
        let eMinX = s.a.x
        let eMaxX = s.b.x
        
        let eMinY: Int64
        let eMaxY: Int64
        if s.a.y > s.b.y {
            eMinY = s.b.y
            eMaxY = s.a.y
        } else {
            eMinY = s.a.y
            eMaxY = s.b.y
        }
        
        let c0 = eMaxX < min.x
        let c1 = eMinX > max.x
        let c2 = eMaxY < min.y
        let c3 = eMinY > max.y
        
        return !(c0 || c1 || c2 || c3)
    }
    
}
