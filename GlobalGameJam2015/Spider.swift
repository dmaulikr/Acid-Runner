//
//  Spider.swift
//  GlobalGameJam2015
//
//  Created by Tomasz Bąk on 24.01.2015.
//  Copyright (c) 2015 Tomasz Bąk. All rights reserved.
//

import SpriteKit

class Spider: NSObject {
    var container: SKScene
    var body: SKSpriteNode = SKSpriteNode()
    var legs: [Leg] = []
    var leftSideLegs: [Leg] = []
    var rightSideLegs: [Leg] = []
    var timeFromLastSlide: NSTimeInterval = 0
    var selectedLeg: Leg?
    let speed: CGFloat = 6
    var wallWidth: CGFloat = 0
    
    var bodyPanning = false
    
    init(container: SKScene) {
        self.container = container
    }
    
    func setupSpiderFor(wallWidth: CGFloat) {
        self.wallWidth = wallWidth
        setupBody()
        legs = setupLegs(wallWidth)
    }
    
    private func setupBody() {
        let bodySize = CGSizeMake(60, 60)
        body = SKSpriteNode(texture: SKTexture(imageNamed: "body_eyes_open"), size: bodySize)
        body.zPosition = ZPosition.Spider.rawValue
        body.position = middleOfContainer()
        
        setupBodyPhysics(body)
        addBlinkingAnimation(body)
        
        container.addChild(body)
    }
    
    private func setupBodyPhysics(body: SKSpriteNode) {
        body.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        body.physicsBody?.affectedByGravity = false
        body.physicsBody?.categoryBitMask = PhysicsCategory.Spider
        body.physicsBody?.collisionBitMask = PhysicsCategory.DroppedItem
        body.shadowCastBitMask = LightingCategory.MainLightSource
    }
    
    private func addBlinkingAnimation(body: SKSpriteNode) {
        let wait = SKAction.waitForDuration(2)
        let frames = [SKTexture(imageNamed: "body_eyes_closed"), SKTexture(imageNamed: "body_eyes_open")]
        let blink = SKAction.animateWithTextures(frames, timePerFrame: 0.1)
        let sequence = SKAction.sequence([wait, blink])
        
        body.runAction(SKAction.repeatActionForever(sequence), withKey: "blink")
    }
    
    private func setupLegs(wallWidth: CGFloat) -> [Leg] {
        leftSideLegs = setupSide(wallWidth)
        rightSideLegs = setupSide(container.size.width - wallWidth)
        
        return leftSideLegs + rightSideLegs
    }
    
    private func setupSide(x: CGFloat) -> [Leg] {
        var list: [Leg] = []
        let initialPositions = [0.4, 0.45, 0.55, 0.6]
        
        for position in initialPositions {
            let narrowEnd = CGPointMake(x, container.size.height * CGFloat(position))
            let leg = createLegAtPoints(narrowEnd, insideEnd: middleOfContainer())
            list.append(leg)
            container.addChild(leg)
        }
        
        return list
    }
    
    private func middleOfContainer() -> CGPoint {
        return CGPointMake(container.size.width / 2, container.size.height / 2)
    }
    
    private func createLegAtPoints(outsideEnd: CGPoint, insideEnd: CGPoint) -> Leg {
        let leg = Leg(texture: SKTexture(imageNamed: "leg"))
        leg.zPosition = ZPosition.SpiderLegs.rawValue
        leg.setupHandle()
        leg.moveEnd(insideEnd)
        leg.moveToPoint(outsideEnd)
        
        return leg
    }
    
    func correctedBodyPosition() -> CGPoint {
        var leftSideAverage = calculateAverageForSide(leftSideLegs);
        var rightSideAverage = calculateAverageForSide(rightSideLegs);
        return CGPointMake(middleOfContainer().x, (leftSideAverage + rightSideAverage) / 2.0)
    }
    
    private func calculateAverageForSide(legs: [Leg]) -> CGFloat {
        var ySum = CGFloat(0);
        for leg in legs {
            ySum += leg.point!.y
        }
        return ySum / CGFloat(legs.count)
    }
    
    func update(delta: NSTimeInterval) {
        slideLegs(delta)
        correctLegsToBodyPositon()
        if !bodyPanning {
            correctBodyPosition()
        }
    }
    
    func slideLegs(delta: NSTimeInterval) {
        let offset = CGFloat(delta) * speed
        
        for leg in legs {
            leg.moveToPoint(CGPointMake(leg.point!.x, leg.point!.y - offset))
        }
    }
    
    func correctBodyPosition() {
        body.removeActionForKey("bounce")
        body.position = correctedBodyPosition()
        correctLegsToBodyPositon()
    }
    
    private func correctLegsToBodyPositon() {
        for leg in legs {
            leg.moveEnd(body.position)
        }
    }
    
    func hadleBodyPan(sender: UIPanGestureRecognizer) {
        let location = container.convertPointToView(sender.locationInView(sender.view))
        
        switch sender.state {
        case .Began:
            if locationInBody(location) {
                bodyPanning = true
            }
        case .Changed:
            if bodyPanning {
                body.position = location
            }
            break
        case .Ended:
            if bodyPanning {
                let move = SKAction.moveTo(correctedBodyPosition(), duration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0)
                body.runAction(move, completion: { () -> Void in
                    self.bodyPanning = false
                })
            }
        default:
            break
            
        }
    }
    
    func didRecognizeLegPan(sender: UIPanGestureRecognizer) {
        let location = container.convertPointToView(sender.locationInView(sender.view))
        
        switch sender.state {
        case .Began:
            selectedLeg = getSelectedLegForLocation(location)
        case .Changed:
            selectedLeg?.moveToPoint(location)
        case .Ended:
            if let leg = selectedLeg {
                if contains(leftSideLegs, leg) {
                    leg.moveToPoint(CGPointMake(wallWidth, leg.point!.y))
                } else {
                    leg.moveToPoint(CGPointMake(container.size.width - wallWidth, leg.point!.y))
                }
            }
            
            selectedLeg = nil
        default:
            break
        }
    }
    
    func getSelectedLegForLocation(location: CGPoint) -> Leg? {
        for node in container.nodesAtPoint(location) {
            let legOrNil = getLegWithSelectedHandle(node as SKSpriteNode)
            
            if let leg = legOrNil {
                return leg
            }
        }
        
        return nil
    }
    
    func getLegWithSelectedHandle(handle: SKSpriteNode) -> Leg? {
        for leg in legs {
            if leg.handle! === handle {
                return leg
            }
        }
        
        return nil
    }

    
    
    
    func locationInBody(location: CGPoint) -> Bool {
        for node in container.nodesAtPoint(location) {
            if node as NSObject == body {
                return true
            }
        }
        
        return false
    }
}
