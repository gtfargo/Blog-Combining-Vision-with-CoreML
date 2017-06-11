//
//  FrameworkExtensions.swift
//  TrackedObjectClassifier
//
//  Created by Jeffrey Bergier on 6/10/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import CoreGraphics

extension CGRect {
    
    func centeringRect() -> CGRect {
        let newOriginX = self.origin.x - self.size.width / 2
        let newOriginY = self.origin.y - self.size.height / 2
        let newOrigin = CGPoint(x: newOriginX, y: newOriginY)
        let newRect = CGRect(origin: newOrigin, size: self.size)
        return newRect
    }
    
//    func centeringAndDoublingSize() -> CGRect {
//        let doubleSize = CGSize(width: self.size.width * 2, height: self.size.height * 2)
//        let doubleRect = CGRect(origin: self.origin, size: doubleSize)
//        let centeredRect = doubleRect.centeringRect()
//        return centeredRect
//    }
}
