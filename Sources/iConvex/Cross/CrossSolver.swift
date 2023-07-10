//
//  CrossSolver.swift
//  
//
//  Created by Nail Sharipov on 10.07.2023.
//

import iFixFloat
import iShape

public struct CrossSolver {
    
    public static func intersect(pathA: [FixVec], pathB: [FixVec]) -> [Pin] {
        let bndA = FixBnd(points: pathA)
        let bndB = FixBnd(points: pathB)
        
        return Self.intersect(pathA: pathA, pathB: pathB, bndA: bndA, bndB: bndB)
    }

    public static func intersect(pathA: [FixVec], pathB: [FixVec], bndA: FixBnd, bndB: FixBnd) -> [Pin] {
        Self.bruteIntersect(pathA: pathA, pathB: pathB, bndA: bndA, bndB: bndB)
    }
    
}
