//
//  Leg.swift
//  GlobalGameJam2015
//
//  Created by Tomasz Bąk on 24.01.2015.
//  Copyright (c) 2015 Tomasz Bąk. All rights reserved.
//

import SpriteKit

class Leg: SKSpriteNode {
    var handle: SKSpriteNode?
    var end: CGPoint?
    
    func setupHandle() {
        anchorPoint = CGPointMake(1, 0.5)
        
        handle = SKSpriteNode(color: UIColor.blueColor(), size: CGSizeMake(40, 40))
        updateHandle()
        addChild(handle!)
    }
    
    func updateHandle() {
        handle?.position = CGPointMake(-self.size.width, 0)
    }
    
    func moveToPoint(start: CGPoint) {
        let vector = vectorFromPoints(start, point2: end!)
        size = CGSizeMake(vector.length(), 10)
        position = end!
        zRotation = vector.angle
        
        updateHandle()
    }
    
    func vectorFromPoints(point1: CGPoint, point2: CGPoint) -> CGVector {
        return CGVectorMake(point2.x - point1.x, point2.y - point1.y);
    }
}
