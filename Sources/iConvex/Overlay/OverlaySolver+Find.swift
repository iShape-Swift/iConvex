//
//  OverlaySolver+Find.swift
//  
//
//  Created by Nail Sharipov on 17.05.2023.
//

import iFixFloat

public struct OverlaySolver {
    
    public static func find(polyA a: [FixVec], polyB b: [FixVec]) -> [Pin] {
        var pins = CrossSolver.intersect(polyA: a, polyB: b)

        guard pins.count > 1 else {
            return pins
        }

        var areas = [FixFloat](repeating: 0, count: pins.count)
        
        for i in 0..<pins.count {
            let pin0 = pins[i]
            let pin1 = pins.next(pin: pin0)

            let aArea = Self.directArea(s0: pin0.a, s1: pin1.a, points: a)
            let bArea = Self.directArea(s0: pin0.b, s1: pin1.b, points: b)
            
            let area = aArea - bArea
            areas[i] = area
        }
        
        var a0 = areas[areas.count - 1]
        for i in 0..<areas.count {
            let a1 = areas[i]

            if a1 > 0 && a0 > 0 {
                pins[i].type = .into_out
            } else if a1 < 0 && a0 < 0 {
                pins[i].type = .out_into
            } else if a0 != 0 && a1 != 0 {
                if a1 > 0 {
                    pins[i].type = .out
                } else {
                    pins[i].type = .into
                }
            } else if a1 == 0 {
                if a0 > 0 {
                    pins[i].type = .into_empty
                } else {
                    pins[i].type = .out_empty
                }
            } else if a0 == 0 {
                if a1 > 0 {
                    pins[i].type = .empty_out
                } else {
                    pins[i].type = .empty_into
                }
            }
            

#if DEBUG
            pins[i].a0 = a0 / 1024
            pins[i].a1 = a1 / 1024
#endif
            
            a0 = a1
        }

        return pins
    }


    static func directArea(s0: PointStone, s1: PointStone, points: [FixVec]) -> FixFloat {
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