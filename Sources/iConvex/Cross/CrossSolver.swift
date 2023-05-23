//
//  CrossSolver.swift
//  
//
//  Created by Nail Sharipov on 20.05.2023.
//

import iFixFloat

import iFixFloat

public struct CrossSolver {
    
    public static func intersect(polyA: [FixVec], polyB: [FixVec]) -> [Pin] {
        let bndA = Boundary(points: polyA)
        let bndB = Boundary(points: polyB)
        
        return Self.bruteIntersect(polyA: polyA, polyB: polyB, bndA: bndA, bndB: bndB)
    }

}
