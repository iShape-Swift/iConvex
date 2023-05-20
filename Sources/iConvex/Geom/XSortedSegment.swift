//
//  Segment.swift
//  
//
//  Created by Nail Sharipov on 16.05.2023.
//

import iFixFloat

public struct CrossResult {
    let type: CrossType
    let point: FixVec
}

public enum CrossType {
    case not_cross          // no intersections
    case pure               // simple intersection with no overlaps or common points
    case same_line          // same line
    
    case end_a0
    case end_a1
    case end_b0
    case end_b1
    case end_a0_b0
    case end_a0_b1
    case end_a1_b0
    case end_a1_b1
    
}

// a.x < b.x (bitPack)
public struct XSortedSegment {

    public let a: FixVec
    public let b: FixVec

    public func cross(_ other: XSortedSegment) -> CrossResult {
        guard !self.yTest(other: other) else {
            return .init(type: .not_cross, point: .zero)
        }

        let a0 = self.a
        let a1 = self.b

        let b0 = other.a
        let b1 = other.b
        
        let d0 = Self.isCCW(a: a0, b: b0, c: b1)
        let d1 = Self.isCCW(a: a1, b: b0, c: b1)
        let d2 = Self.isCCW(a: a0, b: a1, c: b0)
        let d3 = Self.isCCW(a: a0, b: a1, c: b1)

        if d0 == 0 || d1 == 0 || d2 == 0 || d3 == 0 {
            if d0 == 0 && d1 == 0 && d2 == 0 && d3 == 0 {
                return .init(type: .same_line, point: .zero)
            }
            if d0 == 0 {
                if d2 == 0 || d3 == 0 {
                    if d2 == 0 {
                        return .init(type: .end_a0_b0, point: a0)
                    } else {
                        return .init(type: .end_a0_b1, point: a0)
                    }
                } else if d2 != d3 {
                    return .init(type: .end_a0, point: a0)
                } else {
                    return .init(type: .not_cross, point: .zero)
                }
            }
            if d1 == 0 {
                if d2 == 0 || d3 == 0 {
                    if d2 == 0 {
                        return .init(type: .end_a1_b0, point: a1)
                    } else {
                        return .init(type: .end_a1_b1, point: a1)
                    }
                } else if d2 != d3 {
                    return .init(type: .end_a1, point: a1)
                } else {
                    return .init(type: .not_cross, point: .zero)
                }
            }
            if d0 != d1 {
                if d2 == 0 {
                    return .init(type: .end_b0, point: b0)
                } else {
                    return .init(type: .end_b1, point: b1)
                }
            } else {
                return .init(type: .not_cross, point: .zero)
            }
        } else if d0 != d1 && d2 != d3 {
            let cross = Self.crossPoint(a0: a0, a1: a1, b0: b0, b1: b1)

            // still can be ends
            let isA0 = a0 == cross
            let isA1 = a1 == cross
            let isB0 = b0 == cross
            let isB1 = b1 == cross
            
            let type: CrossType
            
            if !(isA0 || isA1 || isB0 || isB1) {
                type = .pure
            } else if isA0 && isB0 {
                type = .end_a0_b0
            } else if isA0 && isB1 {
                type = .end_a0_b1
            } else if isA1 && isB0 {
                type = .end_a1_b0
            } else if isA1 && isB1 {
                type = .end_a1_b1
            } else if isA0 {
                type = .end_a0
            } else if isA1 {
                type = .end_a1
            } else if isB0 {
                type = .end_b0
            } else {
                type = .end_b1
            }
            
            return .init(type: type, point: cross)
        } else {
            return .init(type: .not_cross, point: .zero)
        }
    }
    
    private static func isCCW(a: FixVec, b: FixVec, c: FixVec) -> Int {
        let m0 = (c.y - a.y) * (b.x - a.x)
        let m1 = (b.y - a.y) * (c.x - a.x)

        if m0 < m1 {
            return -1
        }
        
        if m0 > m1 {
            return 1
        }

        return 0
    }
    
    private static func crossPoint(a0: FixVec, a1: FixVec, b0: FixVec, b1: FixVec) -> FixVec {
        let dxA = a0.x - a1.x
        let dyB = b0.y - b1.y
        let dyA = a0.y - a1.y
        let dxB = b0.x - b1.x
        
        let divider = dxA.mul(dyB) - dyA.mul(dxB)
        
        let xyA = a0.x.mul(a1.y) - a0.y.mul(a1.x)
        let xyB = b0.x.mul(b1.y) - b0.y.mul(b1.x)
        
        let x = xyA.mul(b0.x - b1.x) - (a0.x - a1.x).mul(xyB)
        let y = xyA.mul(b0.y - b1.y) - (a0.y - a1.y).mul(xyB)

        let cx = x.div(divider)
        let cy = y.div(divider)
        
        return FixVec(cx, cy)
    }
 
    private func yTest(other: XSortedSegment) -> Bool {
        let y0_min: Int64
        let y0_max: Int64
        
        if a.y > b.y {
            y0_min = b.y
            y0_max = a.y
        } else {
            y0_min = a.y
            y0_max = b.y
        }
        
        let y1_min: Int64
        let y1_max: Int64

        if other.a.y > other.b.y {
            y1_min = other.b.y
            y1_max = other.a.y
        } else {
            y1_min = other.a.y
            y1_max = other.b.y
        }
        
        return y0_max < y1_min || y0_min > y1_max
    }
    
}

