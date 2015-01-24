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
    var point: CGPoint?
    
    func setupHandle() {
        point = CGPointZero
        end = CGPointZero
        anchorPoint = CGPointMake(1, 0.5)
        
        handle = SKSpriteNode(texture: SKTexture(imageNamed: "catch"), size: CGSizeMake(50, 50))
        updateHandle()
        addChild(handle!)
    }
    
    func updateHandle() {
        handle?.position = CGPointMake(-self.size.width, 0)
    }
    
    func moveToPoint(start: CGPoint) {
        var pos = start
        let vec = vectorFromPoints(start, point2: end!);
        if vec.length() > 200 {
            let vec2  = vec.normalized() * -200.0
            pos = end!.offset(dx: vec2.dx, dy: vec2.dy)
        }
        
        self.point = pos
        updatePos()
        updateHandle()
    }
    
    func moveEnd(end: CGPoint) {
        self.end = end
        updatePos()
        updateHandle()
    }
    
    func updatePos() {
        let vector = vectorFromPoints(point!, point2: end!)
        size = CGSizeMake(vector.length(), 10)
        position = end!
        zRotation = vector.angle
    }
    
    func vectorFromPoints(point1: CGPoint, point2: CGPoint) -> CGVector {
        return CGVectorMake(point2.x - point1.x, point2.y - point1.y);
    }
}
