//
//  GameScene.swift
//  GlobalGameJam2015
//
//  Created by Tomasz Bąk on 23.01.2015.
//  Copyright (c) 2015 Tomasz Bąk. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var legs: [SKSpriteNode]?
    
    override func didMoveToView(view: SKView) {
        createSpiderLegs()
    }
    
    func createSpiderLegs() {
        let div = [1.0/3.0, 1.0/2.0, 2.0/3.0]
        for val in div {
            createLegs(CGPointMake(0, self.size.height * CGFloat(val)))
            createLegs(CGPointMake(self.size.width, self.size.height * CGFloat(val)))
        }
        
    }
    
    func createLegs(start: CGPoint) {
        let end = CGPointMake(self.size.width / 2, self.size.height / 2)
        let node = createLegAtPoints(start, end:end)
        legs?.append(node)
        self.addChild(node)
    }

    func createLegAtPoints(start: CGPoint, end: CGPoint) -> SKSpriteNode {
        let vector = vectorFromPoints(start, point2: end)
        let size = CGSizeMake(vector.length(), 10)
        let leg = SKSpriteNode(color: UIColor.blackColor(), size: size)
        leg.anchorPoint = CGPointMake(1, 0.5)
        leg.position = end
        leg.zRotation = vector.angle
        return leg
    }
    
    func vectorFromPoints(point1: CGPoint, point2: CGPoint) -> CGVector {
        return CGVectorMake(point2.x - point1.x, point2.y - point1.y);
    }
}
