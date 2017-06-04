//
//  ECAView.swift
//  ECA
//
//  Created by nst on 03.06.17.
//  Copyright © 2017 Nicolas Seriot. All rights reserved.
//

import Cocoa

@objc protocol ECAViewDelegate {
    var ecaModel: ECAModel { get }
}

class ECAView: NSView {

    let CELL_SIZE = 8
    var delegate: ECAViewDelegate?
    var colFlipInitialState: Int?
    
    override var isFlipped:Bool {
        get {
            return true
        }
    }
    
    override var isOpaque : Bool {
        return false
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let c = NSGraphicsContext.current()?.cgContext else { assertionFailure(); return }
        
        c.setShouldAntialias(false)
        
        c.setFillColor(NSColor.white.cgColor)

        let NB_COL = Int(self.frame.size.width / CGFloat(CELL_SIZE))
        let NB_ROW = Int(self.frame.size.height / CGFloat(CELL_SIZE))

        let whiteBounds = CGRect(x: 0, y: 0, width: NB_COL*CELL_SIZE, height: NB_ROW*CELL_SIZE)
        
        c.fill(whiteBounds)
        
        c.setStrokeColor(NSColor.gray.cgColor)
        
        guard let model = delegate?.ecaModel else { assertionFailure(); return }
        var row = model.firstRow
        
        for rowIndex in 0..<NB_ROW {
            self.drawRow(row: row, rowIndex:rowIndex, context:c)
            row = model.next(row: row)
        }
    }
    
    func rectForCell(col:Int, row:Int) -> CGRect {
        return CGRect(x: col * CELL_SIZE,
                      y: row * CELL_SIZE,
                      width: CELL_SIZE,
                      height: CELL_SIZE)
    }

    func drawRow(row: [Int], rowIndex: Int, context c: CGContext) {
        
        for (i,cell) in row.enumerated() {
            let rect = self.rectForCell(col: i, row: rowIndex)
            
            var fillColor = NSColor.white
            if cell == 1 {
                fillColor = NSColor.black
            }
            
            c.setFillColor(fillColor.cgColor)
            c.fill(rect)
            
            c.setStrokeColor(NSColor.lightGray.cgColor)
            c.stroke(rect)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        
        let clickPoint = convert(event.locationInWindow, from: self.superview)

        //if clickPoint.y > CGFloat(CELL_SIZE) { return }
        
        let col = Int(clickPoint.x / CGFloat(CELL_SIZE))
        
        colFlipInitialState = delegate?.ecaModel.firstRow[col]
        delegate?.ecaModel.flipColumn(column: col)
        
        self.needsDisplay = true
    }
    
    override func mouseDragged(with event: NSEvent) {
        let clickPoint = convert(event.locationInWindow, from: self.superview)
        let col = Int(clickPoint.x / CGFloat(CELL_SIZE))
        if delegate?.ecaModel.firstRow[col] != colFlipInitialState { return }

        colFlipInitialState = delegate?.ecaModel.firstRow[col]
        delegate?.ecaModel.flipColumn(column: col)
        
        self.needsDisplay = true
    }
}

extension NSView {
    func PNGRepresentation() -> Data? {
        guard let rep = self.bitmapImageRepForCachingDisplay(in: self.bounds) else { return nil }
        self.cacheDisplay(in: self.bounds, to: rep)
        return rep.representation(using: .PNG, properties: [:])
    }
}
