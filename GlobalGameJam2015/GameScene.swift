//
//  GameScene.swift
//  GlobalGameJam2015
//
//  Created by Tomasz Bąk on 23.01.2015.
//  Copyright (c) 2015 Tomasz Bąk. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, UIGestureRecognizerDelegate, SKPhysicsContactDelegate {
    var lastUpdate: NSTimeInterval = 0
    var selected: Leg?
    var recon: Bool?
    
    var leftWall: SKSpriteNode?
    var rightWall: SKSpriteNode?
    var background: SKSpriteNode?
    
    var lightNode: SKLightNode?
    
    let baseColor: SKColor = SKColorWithRGB(170, 57, 57)
    let secondaryColor: SKColor = SKColorWithRGB(128, 21, 21)
    let shadowColor: SKColor = SKColorWithRGBA(0, 0, 0, 60)
    
    let mainLightningBitMask: UInt32 = 1
    
    var correctingBody = true
    
    var spider: Spider?
    
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(texture: SKTexture(imageNamed: "tlo"), size: self.size)
        background.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        addChild(background)
        
        let acid = SKSpriteNode(color: UIColor(red: 1, green: 1, blue: 0, alpha: 0.3), size: CGSizeMake(320, 568))
        acid.position = CGPointMake(self.size.width / 2, -200)
        acid.zPosition = 1
        acid.physicsBody = SKPhysicsBody(rectangleOfSize: acid.size)
        acid.physicsBody?.dynamic = false
        acid.physicsBody?.contactTestBitMask = 0x1 << 0
        addChild(acid)
        
        spider = Spider(container: self)
        spider!.setupSpiderFor(35.0)
        
        createSceneContents(view)
//        recon = true
//        let recognizer = UIPanGestureRecognizer(target: self, action:Selector("hadle:"))
//        view.addGestureRecognizer(recognizer)
//        recognizer.delegate = self
//        
        let bodyPanRecognizer = UIPanGestureRecognizer(target: spider!, action:Selector("hadleBodyPan:"))
        view.addGestureRecognizer(bodyPanRecognizer)
        bodyPanRecognizer.delegate = self
        
        self.physicsWorld.contactDelegate = self
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
//        self.view?.paused = true
//        let label = SKLabelNode(text: "Game over!")
//        label.position = CGPointMake(self.size.width / 2, self.size.height / 2)
//        label.fontSize = 60
//        label.zPosition = 2
//        addChild(label)
    }
    
    func createSceneContents(view: SKView) {
        let wallWidth = CGFloat(35)
        let wallHeight = view.frame.height
        
        createLeftWall(view, wallWidth: wallWidth, wallHeight: wallHeight)
        createRightWall(view, wallWidth: wallWidth, wallHeight: wallHeight)
        createBackground(view, wallWidth: wallWidth, wallHeight: wallHeight)
        
        letThereBeLight(view)
    }
    
    func createLeftWall(view: SKView, wallWidth: CGFloat, wallHeight: CGFloat) {
        var wallNode = SKSpriteNode(color: secondaryColor, size: CGSize(width: wallWidth, height: wallHeight))
        wallNode.zPosition = 1
        wallNode.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: 0, width: wallWidth, height: CGRectGetHeight(view.frame)))
        wallNode.position = CGPoint(x: CGRectGetWidth(wallNode.frame)/2, y: CGRectGetHeight(view.frame)/2)
        wallNode.lightingBitMask = mainLightningBitMask
        addChild(wallNode)
        leftWall = wallNode
    }
    
    func createRightWall(view: SKView, wallWidth: CGFloat, wallHeight: CGFloat) {
        var wallNode = SKSpriteNode(color: secondaryColor, size: CGSize(width: wallWidth, height: wallHeight))
        wallNode.zPosition = 1
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
        light.position = CGPoint(x: CGRectGetWidth(view.frame)/2.0, y: CGRectGetHeight(view.frame) + 100.0)
        light.categoryBitMask = mainLightningBitMask
        light.ambientColor = secondaryColor
        light.shadowColor = shadowColor
        light.falloff = 2
        addChild(light)
        lightNode = light
    }
    
//    func hadle(sender: UIPanGestureRecognizer) {
//        let location = sender.locationInView(sender.view)
//        let location2 = self.convertPointToView(location)
//        var leave = false
//        
//        for test in nodesAtPoint(location2) {
//            let handle = test as SKSpriteNode
//            
//            for leg in nodes {
//                if leg.handle! === handle {
//                    switch sender.state {
//                        case .Began:
//                            recon = false
//                            selected = leg
//                            handle.color = UIColor.yellowColor()
//                        default:
//                        break
//                    }
//                    leave = true
//                    break
//                }
//            }
//            if leave {
//                break
//            }
//        }
//        
//        if selected == nil {
//            return
//        }
//        
//        switch sender.state {
//        case .Changed:
//            selected?.moveToPoint(location2)
//        case .Ended:
//            if let sel = selected {
//                if contains(leftLegs!, sel) {
//                    sel.moveToPoint(CGPointMake(35, selected!.point!.y))
//                } else {
//                    sel.moveToPoint(CGPointMake(self.size.width - 35, selected!.point!.y))
//                }
//            }
//            
//            selected?.handle?.color = UIColor.blueColor()
//            selected = nil
//            recon = true
//            body?.removeActionForKey("bounce")
//            body?.position = correctBodyPosition()
//        default:
//            break
//        }
//    }
//    
//    func hadle2(sender: UIPanGestureRecognizer) {
//        if(!recon!) {
//            return
//        }
//        let location = sender.locationInView(sender.view)
//        let location2 = self.convertPointToView(location)
//        
//        for test in nodesAtPoint(location2) {
//            if body! === test {
//                switch sender.state {
//                    case .Began:
//                        correctingBody = false
//                        body?.removeActionForKey("bounce")
//                    case .Changed:
//                        body?.position = location2
//                    case .Ended:
//                        correctingBody = false;
//                        let move = SKAction.moveTo(correctBodyPosition(), duration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0)
//                        body?.runAction(move, completion: { () -> Void in
//                            self.correctingBody = true
//                        })
//                    
//                    
//                default:
//                    break
//                }
//            }
//        }
//    }
    
    
    
    override func update(currentTime: NSTimeInterval) {
        if lastUpdate == 0 {
            lastUpdate = currentTime
        }
        
        let delta = currentTime - lastUpdate
        
        if let spider = self.spider {
            spider.update(currentTime - lastUpdate)
        }
        
        lastUpdate = currentTime
    }
    
//    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
}
