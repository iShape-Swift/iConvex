//
//  Edge.swift
//  
//
//  Created by Nail Sharipov on 20.05.2023.
//

import iFixFloat

struct Edge {
    
    static let empty = Edge(shapeId: -1, start: .zero, end: .zero, p0: .zero, p1: .zero)
    
    let shapeId: Int
    let start: FixVec
    let end: FixVec
    let p0: IndexPoint
    let p1: IndexPoint
    
    init(shapeId: Int, start: FixVec, end: FixVec, p0: IndexPoint, p1: IndexPoint) {
        self.shapeId = shapeId
        self.start = start
        self.end = end
        self.p0 = p0
        self.p1 = p1
    }
    
    init(parent: Edge, start: FixVec, end: FixVec) {
        self.shapeId = parent.shapeId
        self.start = start
        self.end = end
        self.p0 = parent.p0
        self.p1 = parent.p1
    }
    
    init(parent: Edge, a: FixVec, b: FixVec) {
        if a.bitPack < b.bitPack {
            self.start = a
            self.end = b
        } else {
            self.start = b
            self.end = a
        }
        self.shapeId = parent.shapeId
        self.p0 = parent.p0
        self.p1 = parent.p1
    }
    
}
