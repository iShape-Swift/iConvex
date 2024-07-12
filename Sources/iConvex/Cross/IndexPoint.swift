//
//  IndexPoint.swift
//
//
//  Created by Nail Sharipov on 12.07.2024.
//

import iFixFloat

struct IndexPoint {
    
    static let zero = IndexPoint(index: 0, point: .zero)
    
    let index: Int
    let point: FixVec
    
    init(index: Int, point: FixVec) {
        self.index = index
        self.point = point
    }
}
