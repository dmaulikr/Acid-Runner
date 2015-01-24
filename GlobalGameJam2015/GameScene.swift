//
//  GameScene.swift
//  GlobalGameJam2015
//
//  Created by Tomasz Bąk on 23.01.2015.
//  Copyright (c) 2015 Tomasz Bąk. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, UIGestureRecognizerDelegate {
    var nodes: [Leg]?
    var selected: Leg?
    var body: SKSpriteNode?
    var recon: Bool?
    
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
        createBody()
        recon = true
        let recognizer = UIPanGestureRecognizer(target: self, action:Selector("hadle:"))
        view.addGestureRecognizer(recognizer)
        recognizer.delegate = self
        
        let recognizer2 = UIPanGestureRecognizer(target: self, action:Selector("hadle2:"))
        view.addGestureRecognizer(recognizer2)
        recognizer2.delegate = self
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
        let leg = Leg(texture: SKTexture(imageNamed: "noga"))
        leg.setupHandle()
        leg.moveEnd(end)
        leg.moveToPoint(start)
        leg.lightingBitMask = mainLightningBitMask
        nodes?.append(leg)
        
        return leg
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
    

    func createBody() {
        body = SKSpriteNode(texture: SKTexture(imageNamed: "korpusik"))
        body?.size = CGSizeMake(80, 80)
        body?.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        addChild(body!)
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
    
    func hadle(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(sender.view)
        let location2 = self.convertPointToView(location)
        
        switch sender.state {
            case .Changed:
                selected?.moveToPoint(location2)
            case .Ended:
                selected?.handle?.color = UIColor.blueColor()
                selected = nil
                recon = true
            default:
                break
        }

        
        for test in nodesAtPoint(location2) {
            let handle = test as SKSpriteNode
            
            for leg in nodes! {
                if leg.handle! === handle {
                    switch sender.state {
                        case .Began:
                            recon = false
                            selected = leg
                            handle.color = UIColor.yellowColor()
                        default:
                        break
                    }
                    break
                }
            }
        }
    }
    
    func hadle2(sender: UIPanGestureRecognizer) {
        if(!recon!) {
            return
        }
        let location = sender.locationInView(sender.view)
        let location2 = self.convertPointToView(location)
        
        for test in nodesAtPoint(location2) {
            if body! === test {
                switch sender.state {
                    case .Changed:
                        body?.position = location2
                        for leg in nodes! {
                            leg.moveEnd(location2)
                        }
                    case .Ended:
                        let move = SKAction.moveTo(CGPointMake(self.size.width / 2, self.size.height / 2), duration: 0.5)
                        let move2 = SKAction.moveTo(CGPointMake(self.size.width / 2, self.size.height / 2), duration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0)
                        body?.runAction(move2)
                    
                default:
                    break
                }
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        for leg in nodes! {
            let pos = self.body?.position
            leg.moveEnd(pos!)
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
