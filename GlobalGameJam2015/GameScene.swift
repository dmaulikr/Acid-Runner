//
//  GameScene.swift
//  GlobalGameJam2015
//
//  Created by Tomasz Bąk on 23.01.2015.
//  Copyright (c) 2015 Tomasz Bąk. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var nodes: [SKSpriteNode]?
    
    var leftWall: SKSpriteNode?
    var rightWall: SKSpriteNode?
    var background: SKSpriteNode?
    
    var lightNode: SKLightNode?
    
    let baseColor: SKColor = SKColorWithRGB(170, 57, 57)
    let secondaryColor: SKColor = SKColorWithRGB(128, 21, 21)
    
    let mainLightningBitMask: UInt32 = 1
    
    
    override func didMoveToView(view: SKView) {
        nodes = []
        createSceneContents(view)
        createSpiderLegs()
        
        
        let recognizer = UITapGestureRecognizer(target: self, action:Selector("hadle:"))
        view.addGestureRecognizer(recognizer)
    }
    
    func createSpiderLegs() {
        let div = [1.0/3.0, 1.0/2.0, 2.0/3.0]
        for val in div {
            createLegs(CGPointMake(30, self.size.height * CGFloat(val)))
            createLegs(CGPointMake(self.size.width-30, self.size.height * CGFloat(val)))
        }
    }
    
    func createSceneContents(view: SKView) {
        let wallWidth = CGFloat(35)
        let wallHeight = view.frame.height
        
        createLeftWall(view, wallWidth: wallWidth, wallHeight: wallHeight)
        createRightWall(view, wallWidth: wallWidth, wallHeight: wallHeight)
        createBackground(view, wallWidth: wallWidth, wallHeight: wallHeight)
        
        letThereBeLight(view)
    }
    
    func createLegs(start: CGPoint) {
        let end = CGPointMake(self.size.width / 2, self.size.height / 2)
        let node = createLegAtPoints(start, end:end)
        self.addChild(node)
    }

    func createLegAtPoints(start: CGPoint, end: CGPoint) -> SKSpriteNode {
        let vector = vectorFromPoints(start, point2: end)
        let size = CGSizeMake(vector.length(), 10)
        let leg = SKSpriteNode(color: UIColor.blackColor(), size: size)
        leg.anchorPoint = CGPointMake(1, 0.5)
        leg.position = end
        leg.zRotation = vector.angle
        
        let handle = SKSpriteNode(color: UIColor.blueColor(), size: CGSizeMake(40, 40))
        handle.position = CGPointMake(-leg.size.width, 0)
        handle.lightingBitMask = mainLightningBitMask
        leg.addChild(handle)
        nodes?.append(handle)
        
        return leg
    }
    
    func vectorFromPoints(point1: CGPoint, point2: CGPoint) -> CGVector {
        return CGVectorMake(point2.x - point1.x, point2.y - point1.y);
    }

    func createLeftWall(view: SKView, wallWidth: CGFloat, wallHeight: CGFloat) {
        var wallNode = SKSpriteNode(color: secondaryColor, size: CGSize(width: wallWidth, height: wallHeight))
        wallNode.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: 0, width: wallWidth, height: CGRectGetHeight(view.frame)))
        wallNode.position = CGPoint(x: CGRectGetWidth(wallNode.frame)/2, y: CGRectGetHeight(view.frame)/2)
        wallNode.lightingBitMask = mainLightningBitMask
        addChild(wallNode)
        leftWall = wallNode
    }
    
    func createRightWall(view: SKView, wallWidth: CGFloat, wallHeight: CGFloat) {
        var wallNode = SKSpriteNode(color: secondaryColor, size: CGSize(width: wallWidth, height: wallHeight))
        wallNode.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: CGRectGetWidth(view.frame) - CGRectGetWidth(view.frame), y: 0, width: wallWidth, height: CGRectGetHeight(view.frame)))
        wallNode.position = CGPoint(x: CGRectGetWidth(view.frame) - CGRectGetWidth(wallNode.frame)/2, y: CGRectGetHeight(view.frame)/2)
        wallNode.lightingBitMask = mainLightningBitMask
        addChild(wallNode)
        rightWall = wallNode
    }
    
    func createBackground(view: SKView, wallWidth: CGFloat, wallHeight: CGFloat) {
        var backgroundNode = SKSpriteNode(color: baseColor, size: CGSizeMake(CGRectGetWidth(view.frame)-wallWidth*2, CGRectGetHeight(view.frame)))
        backgroundNode.position = CGPoint(x: CGRectGetWidth(view.frame)/2.0, y: CGRectGetHeight(view.frame)/2.0)
        backgroundNode.lightingBitMask = mainLightningBitMask
        addChild(backgroundNode)
        background = backgroundNode
    }
    
    func letThereBeLight(view: SKView) {
        var light = SKLightNode()
        light.position = CGPoint(x: CGRectGetWidth(view.frame)/2.0, y: CGRectGetHeight(view.frame) + 50.0)
        light.categoryBitMask = mainLightningBitMask
        light.ambientColor = secondaryColor
        addChild(light)
        lightNode = light
    }
    
    func hadle(sender: UITapGestureRecognizer) {
        let location = sender.locationInView(sender.view)
        let location2 = self.convertPointToView(location)
        for test in nodesAtPoint(location2) {
            let handle = test as SKSpriteNode
            if contains(nodes!, handle) {
                handle.color = UIColor.yellowColor()
            }
        }
    }
}
