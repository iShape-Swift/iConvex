//
//  IdEdge+Cross.swift
//
//
//  Created by Nail Sharipov on 10.01.2024.
//

import iFixFloat
import iShape

struct EdgeCross {

    let type: EdgeCrossType
    let point: FixVec

    @usableFromInline
    init(type: EdgeCrossType, point: FixVec) {
        self.type = type
        self.point = point
    }
}

enum EdgeCrossType {
    case pure               // simple intersection with no overlaps or common points
    
    case end_a
    case end_b
    
    case common_end
}

struct EdgeCrosser {
    
    static func cross(a0: FixVec, a1: FixVec, b0: FixVec, b1: FixVec) -> EdgeCross? {
        let d0 = Triangle.clockDirection(p0: a0, p1: b0, p2: b1)
        let d1 = Triangle.clockDirection(p0: a1, p1: b0, p2: b1)
        let d2 = Triangle.clockDirection(p0: a0, p1: a1, p2: b0)
        let d3 = Triangle.clockDirection(p0: a0, p1: a1, p2: b1)

        var p: FixVec = .zero
        var type: EdgeCrossType?
        
        if d0 == 0 || d1 == 0 || d2 == 0 || d3 == 0 {
            if !(d0 == 0 && d1 == 0 && d2 == 0 && d3 == 0) {
                if d0 == 0 {
                    p = a0
                    if d2 == 0 || d3 == 0 {
                        type = .common_end
                    } else if d2 != d3 {
                        type = .end_a
                    }
                } else if d1 == 0 {
                    p = a1
                    if d2 == 0 || d3 == 0 {
                        type = .common_end
                    } else if d2 != d3 {
                        type = .end_a
                    }
                } else if d0 != d1 {
                    if d2 == 0 {
                        p = b0
                    } else {
                        p = b1
                    }
                    type = .end_b
                }
            }
        } else if d0 != d1 && d2 != d3 {
            p = Self.crossPoint(a0: a0, a1: a1, b0: b0, b1: b1)

            // still can be ends
            let isA0 = a0 == p
            let isA1 = a1 == p
            let isB0 = b0 == p
            let isB1 = b1 == p
            
            if !(isA0 || isA1 || isB0 || isB1) {
                type = .pure
            } else if isA0 && isB0 || isA0 && isB1 || isA1 && isB0 || isA1 && isB1 {
                type = .common_end
            } else if isA0 || isA1 {
                type = .end_a
            } else if isB0 || isB1 {
                type = .end_b
            }
        }
        
        if let type = type {
            return EdgeCross(type: type, point: p)
        } else {
            return nil
        }
    }
    
    private static func crossPoint(a0: FixVec, a1: FixVec, b0: FixVec, b1: FixVec) -> FixVec {
        let dxA = a0.x - a1.x
        let dyB = b0.y - b1.y
        let dyA = a0.y - a1.y
        let dxB = b0.x - b1.x

        let xyA = a0.x * a1.y - a0.y * a1.x
        let xyB = b0.x * b1.y - b0.y * b1.x
        
        let x = xyA * dxB - dxA * xyB
        let y = xyA * dyB - dyA * xyB

        let divider = dxA * dyB - dyA * dxB
        
        let cx = x / divider
        let cy = y / divider
        
        return FixVec(cx, cy)
    }

}
