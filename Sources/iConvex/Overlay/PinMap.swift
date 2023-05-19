
//
//  PinMap.swift
//  
//
//  Created by Nail Sharipov on 19.05.2023.
//

import iFixFloat

public struct Pin {
    fileprivate let a: Int  // index in pins
    fileprivate let b: Int  // index in queue B
    public let dot: PinDot
}

private struct SortStone {
    let i: Int
    let m: MileStone
}

public struct PinMap {
    
    private let queueB: [Int] // index on pins
    public let pins: [Pin]

    public var isEmpty: Bool { pins.isEmpty }
    
    init() {
        pins = []
        queueB = []
    }
    
    init(dots: [PinDot]) {
        let n = dots.count
        
        let aDots = dots.sorted(by: { $0.mA < $1.mA }) // sort by A
        
        var stList = [SortStone](repeating: SortStone(i: 0, m: .zero), count: n)
        
        // for B
        for i in 0..<n {
            stList[i] = SortStone(i: i, m: aDots[i].mB)
        }
        stList.sort(by: { $0.m < $1.m})

        var queueB = [Int](repeating: 0, count: n)
        for i in 0..<n {
            let j = stList[i].i
            queueB[j] = i
        }

        var pins = [Pin](repeating: Pin(a: 0, b: 0, dot: PinDot(p: .zero, mA: .zero, mB: .zero)), count: n)
        for i in 0..<n {
            pins[i] = Pin(a: i, b: queueB[i], dot: aDots[i])
        }
        
        self.pins = pins
        self.queueB = queueB
    }
    
    func nextA(pin: Pin) -> Pin {
        let i = pin.a.next(pins.count)
        return pins[i]
    }
    
    func nextB(pin: Pin) -> Pin {
        let i = pin.b.next(pins.count)
        let j = queueB[i] // back to pins index
        return pins[j]
    }

}
