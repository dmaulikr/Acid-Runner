//
//  GameScene.swift
//  GlobalGameJam2015
//
//  Created by Tomasz Bąk on 23.01.2015.
//  Copyright (c) 2015 Tomasz Bąk. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, UIGestureRecognizerDelegate, SKPhysicsContactDelegate {
    var nodes: [Leg] = []
    var selected: Leg?
    var body: SKSpriteNode?
    var recon: Bool?
    var leftLegs: [Leg]?
    var rightLegs: [Leg]?
    
    var leftWall: SKSpriteNode?
    var rightWall: SKSpriteNode?
    var background: SKSpriteNode?
    
    var lightNode: SKLightNode?
    
    let wallWidth: CGFloat = 35.0
    
    let baseColor: SKColor = SKColorWithRGB(170, 57, 57)
    let secondaryColor: SKColor = SKColorWithRGB(128, 21, 21)
    let shadowColor: SKColor = SKColorWithRGBA(0, 0, 0, 60)
    
    let mainLightningBitMask: UInt32 = 1
    
    var correctingBody = true
    
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
        
        nodes = []
        leftLegs = []
        rightLegs = []
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
        
        startUpMyGravityPlayground(view)
        self.physicsWorld.contactDelegate = self
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        self.view?.paused = true
        let label = SKLabelNode(text: "Game over!")
        label.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        label.fontSize = 60
        label.zPosition = 2
        addChild(label)
    }

    func startUpMyGravityPlayground(view: SKView) {
        self.physicsWorld.gravity = CGVectorMake(0.0, -1.0)
        
        var waitAction = SKAction.waitForDuration(5.0)
        var dropItemAction = SKAction.runBlock {
            self.createBalls(view)
        }
        
        var sequence = SKAction.sequence([waitAction, dropItemAction])
        
        runAction(SKAction.repeatActionForever(sequence))
    }
    
    func createBalls(view: SKView) {
        let offsetFromWalls = CGFloat(10)
        let ballsDropPointOffset = CGFloat(50)
        let ballSize = CGSize(width: 10.0, height: 10.0)
        
        var ball = SKSpriteNode(color: UIColor.greenColor(), size: ballSize)
        ball.position = CGPoint(x: CGFloat.random(min: wallWidth + offsetFromWalls, max: CGRectGetWidth(view.frame) - wallWidth - offsetFromWalls), y: CGRectGetHeight(view.frame) + ballsDropPointOffset)
        ball.zPosition = 1.0
        addChild(ball)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballSize.width/2.0)
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.collisionBitMask = 1
        ball.physicsBody?.contactTestBitMask = 1
    }
    
    func createSpiderLegs() {
        let div = [1.0/3.0, 1.0/2.0, 2.0/3.0]
        for val in div {
            let left = createLegs(CGPointMake(35, self.size.height * CGFloat(val)))
            let right = createLegs(CGPointMake(self.size.width-35, self.size.height * CGFloat(val)))
            leftLegs?.append(left)
            rightLegs?.append(right)
        }
    }
    
    func createSceneContents(view: SKView) {
        let wallHeight = view.frame.height
        
        createLeftWall(view, wallWidth: wallWidth, wallHeight: wallHeight)
        createRightWall(view, wallWidth: wallWidth, wallHeight: wallHeight)
        createBackground(view, wallWidth: wallWidth, wallHeight: wallHeight)
        
        letThereBeLight(view)
    }
    
    func createLegs(start: CGPoint) -> Leg {
        let end = CGPointMake(self.size.width / 2, self.size.height / 2)
        let node = createLegAtPoints(start, end:end)
        self.addChild(node)
        return node
    }

    func createLegAtPoints(start: CGPoint, end: CGPoint) -> Leg {
        let leg = Leg(texture: SKTexture(imageNamed: "noga"))
        leg.zPosition = 1
        leg.setupHandle()
        leg.moveEnd(end)
        leg.moveToPoint(start)
        leg.lightingBitMask = mainLightningBitMask
        nodes.append(leg)
        
        return leg
    }
    
    func createLeftWall(view: SKView, wallWidth: CGFloat, wallHeight: CGFloat) {
        var wallNode = SKSpriteNode(color: secondaryColor, size: CGSize(width: wallWidth, height: wallHeight))
        wallNode.zPosition = 1
        wallNode.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0.0, y: 0.0, width: wallWidth, height: CGRectGetHeight(view.frame)))
        wallNode.position = CGPoint(x: CGRectGetWidth(wallNode.frame)/2.0, y: CGRectGetHeight(view.frame)/2.0)
        wallNode.lightingBitMask = mainLightningBitMask
        addChild(wallNode)
        leftWall = wallNode
    }
    
    func createRightWall(view: SKView, wallWidth: CGFloat, wallHeight: CGFloat) {
        var wallNode = SKSpriteNode(color: secondaryColor, size: CGSize(width: wallWidth, height: wallHeight))
        wallNode.zPosition = 1
        wallNode.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: CGRectGetWidth(view.frame) - CGRectGetWidth(view.frame), y: 0.0, width: wallWidth, height: CGRectGetHeight(view.frame)))
        wallNode.position = CGPoint(x: CGRectGetWidth(view.frame) - CGRectGetWidth(wallNode.frame)/2.0, y: CGRectGetHeight(view.frame)/2.0)
        wallNode.lightingBitMask = mainLightningBitMask
        addChild(wallNode)
        rightWall = wallNode
    }
    

    func createBody() {
        body = SKSpriteNode(texture: SKTexture(imageNamed: "korpusik"))
        body?.size = CGSizeMake(60, 60)
        body?.zPosition = 1
        body?.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        body?.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        body?.physicsBody?.affectedByGravity = false
        body?.physicsBody?.categoryBitMask = 0x1 << 0
        body?.shadowCastBitMask = mainLightningBitMask
        let wait = SKAction.waitForDuration(2)
        let frames = [SKTexture(imageNamed: "korpusik_mrugniety"), SKTexture(imageNamed: "korpusik")]
        let blink = SKAction.animateWithTextures(frames, timePerFrame: 0.1)
        body?.runAction(SKAction.repeatActionForever(SKAction.sequence([wait, blink])), withKey: "blink")
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
        let lightNodeOffset = CGFloat(100.0)
        light.position = CGPoint(x: CGRectGetWidth(view.frame)/2.0, y: CGRectGetHeight(view.frame) + lightNodeOffset)
        light.categoryBitMask = mainLightningBitMask
        light.ambientColor = secondaryColor
        light.shadowColor = shadowColor
        light.falloff = 2
        addChild(light)
        lightNode = light
    }
    
    func hadle(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(sender.view)
        let location2 = self.convertPointToView(location)
        var leave = false
        
        for test in nodesAtPoint(location2) {
            let handle = test as SKSpriteNode
            
            for leg in nodes {
                if leg.handle! === handle {
                    switch sender.state {
                        case .Began:
                            recon = false
                            selected = leg
                            handle.color = UIColor.yellowColor()
                        default:
                        break
                    }
                    leave = true
                    break
                }
            }
            if leave {
                break
            }
        }
        
        if selected == nil {
            return
        }
        
        switch sender.state {
        case .Changed:
            selected?.moveToPoint(location2)
        case .Ended:
            if let sel = selected {
                if contains(leftLegs!, sel) {
                    sel.moveToPoint(CGPointMake(35, selected!.point!.y))
                } else {
                    sel.moveToPoint(CGPointMake(self.size.width - 35, selected!.point!.y))
                }
            }
            
            selected?.handle?.color = UIColor.blueColor()
            selected = nil
            recon = true
            body?.removeActionForKey("bounce")
            body?.position = correctBodyPosition()
        default:
            break
        }
    }
    
    func correctBodyPosition() -> CGPoint {
        var avr1 = CGFloat(0);
        var avr2 = CGFloat(0);
        for leg in leftLegs! {
            avr1 += leg.point!.y
        }
        for leg in rightLegs! {
            avr2 += leg.point!.y
        }
        avr1 /= CGFloat(leftLegs!.count)
        avr2 /= CGFloat(rightLegs!.count)
        
        return CGPointMake(self.size.width / 2, (avr1 + avr2) / 2.0)
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
                    case .Began:
                        correctingBody = false
                        body?.removeActionForKey("bounce")
                    case .Changed:
                        body?.position = location2
                    case .Ended:
                        correctingBody = false;
                        let move = SKAction.moveTo(correctBodyPosition(), duration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0)
                        body?.runAction(move, completion: { () -> Void in
                            self.correctingBody = true
                        })
                    
                    
                default:
                    break
                }
            }
        }
    }
    
    var lastUpdate: NSTimeInterval = 0
    var sumForSlide: NSTimeInterval = 0
    
    override func update(currentTime: NSTimeInterval) {
        let delta = currentTime - lastUpdate
        
        sumForSlide += delta
        
        if sumForSlide > 0.06 {
            sumForSlide = 0
            
            for leg in nodes {
                leg.moveToPoint(CGPointMake(leg.point!.x, leg.point!.y - 1))
            }
            if correctingBody {
                body?.removeActionForKey("bounce")
                body?.position = correctBodyPosition()
            }
        }
        
        for leg in nodes {
            let pos = self.body?.position
            leg.moveEnd(pos!)
        }
        
        lastUpdate = currentTime
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
