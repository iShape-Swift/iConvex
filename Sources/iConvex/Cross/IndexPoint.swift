//
//  IndexPoint.swift
//  
//
//  Created by Nail Sharipov on 20.05.2023.
//

import iFixFloat


struct IndexPoint {
    
    static let zero = IndexPoint(index: 0, point: .zero)
    
    let index: Int
    let point: FixVec
}

