//
//  RuleView.swift
//  ECA
//
//  Created by nst on 03.06.17.
//  Copyright © 2017 Nicolas Seriot. All rights reserved.
//

import Cocoa

@objc protocol RuleViewDelegate {
    var rule: UInt8 { get set }
}

class RuleView: NSView {
    
    let LEFT_PAD = 8
    let BOTTOM_PAD = 8
    let CELL_SIZE = 16
    
    var bitRects: [CGRect] = []
    
    @IBOutlet weak var delegate: RuleViewDelegate? = nil
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override var isOpaque : Bool {
        return false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        
        for b in 0..<8 {
            let X_BIT_OFFSET = 4 * CELL_SIZE * b
            let rect = CGRect(x: LEFT_PAD + X_BIT_OFFSET + CELL_SIZE, y: LEFT_PAD, width: CELL_SIZE, height: CELL_SIZE)
            bitRects.append(rect)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let c = NSGraphicsContext.current()?.cgContext else { assertionFailure(); return }
        
        c.setShouldAntialias(false)
        
        c.setStrokeColor(NSColor.lightGray.cgColor)
        
        for b in 0..<8 {
            let X_BIT_OFFSET = 4 * CELL_SIZE * b
            for i in 0...2 {
                
                let rect = CGRect(x: LEFT_PAD + X_BIT_OFFSET + i*CELL_SIZE, y: CELL_SIZE+BOTTOM_PAD, width: CELL_SIZE, height: CELL_SIZE)

                var fillColor = NSColor.white
                
                let fill = (7-b) & (1 << (2-i))
                if fill != 0 {
                    fillColor = NSColor.black
                }

                c.setFillColor(fillColor.cgColor)
                c.fill(rect)
                c.stroke(rect)
            }
        }
        
        guard let rule = delegate?.rule else { assertionFailure(); return }
        
        for (i,rect) in bitRects.enumerated() {
            var fillColor = NSColor.white
            let i_uint8 = UInt8(bitPattern: Int8(7-i))
            if (rule & (1 << i_uint8)) != 0 {
                fillColor = NSColor.black
            }
            c.setFillColor(fillColor.cgColor)
            c.fill(rect)
            c.stroke(rect)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        
        let clickPoint = convert(event.locationInWindow, from: self.superview)
        
        guard let rule = delegate?.rule else { assertionFailure(); return }
        
        for (i,rect) in bitRects.enumerated() {
            if rect.contains(clickPoint) == false { continue }
            
            let i_uint8 = UInt8(bitPattern: Int8(7-i))
            let value = 1 << i_uint8
            let bit_is_set = (rule & value) != 0
            
            if bit_is_set {
                delegate?.rule = rule - value
            } else {
                delegate?.rule = rule + value
            }
            
            self.needsDisplay = true
        }        
    }
    
}
