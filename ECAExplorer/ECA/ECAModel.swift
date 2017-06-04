//
//  Model.swift
//  ECA
//
//  Created by nst on 03.06.17.
//  Copyright © 2017 Nicolas Seriot. All rights reserved.
//

import Cocoa

class ECAModel: NSObject {
    
    var firstRow: [Int] = []
    var ruleBits: [Int] = [0,0,0,0,0,0,0,0]
    var rule: UInt8 = 0 {
        didSet {
            let ruleBin = String(rule, radix: 2)
            let ruleBinPad = String(repeating: "0", count: (8 - ruleBin.characters.count)) + ruleBin
            ruleBits = []
            
            assert(ruleBinPad.characters.count == 8)
            
            for c in ruleBinPad.characters {
                switch c {
                case "0":
                    ruleBits.append(0)
                case "1":
                    ruleBits.append(1)
                default:
                    assertionFailure()
                }
            }
            
            ruleBits.reverse()
        }
    }
    
    init(width: Int) {
        self.firstRow = Array(repeating: 0, count: width)
    }
    
    func next(row: [Int]) -> [Int] {

        let r = [row[row.count-1]] + row + [row[0]]
        
        var n: [Int] = []
        
        for i in 0..<row.count {
            let index = r[i]*4 + (r[i+1]*2) + (r[i+2])
            n.append(ruleBits[index])
        }
        
        return n
    }
    
    func flipColumn(column i: Int) {
        firstRow[i] = firstRow[i] == 1 ? 0 : 1
    }
    
}
