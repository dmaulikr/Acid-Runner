//
//  GameScene.swift
//  GlobalGameJam2015
//
//  Created by Tomasz Bąk on 23.01.2015.
//  Copyright (c) 2015 Tomasz Bąk. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None         : UInt32 = 0
    static let All          : UInt32 = UInt32.max
    static let Spider       : UInt32 = 0b1
    static let Acid         : UInt32 = 0b10
    static let Wall         : UInt32 = 0b100
    static let Floor        : UInt32 = 0b1000
    static let DroppedItem  : UInt32 = 0b10000
    static let UsedItem     : UInt32 = 0b100000
}

struct LightingCategory {
    static let None             : UInt32 = 0
    static let All              : UInt32 = UInt32.max
    static let MainLightSource  : UInt32 = 0b1
}

enum ZPosition: CGFloat {
    case Background
    case SpiderLegs
    case Spider
    case Items
    case Acid
    case Walls
    case HUD
}

class GameScene: SKScene, UIGestureRecognizerDelegate, SKPhysicsContactDelegate {
    let acidInitialHeight = CGFloat(40)
    let acidTransparentAreaHeight = CGFloat(44) // funny, innit?

    var lastUpdate: NSTimeInterval = 0
    var selected: Leg?
    var recon: Bool?
    
    var leftWall: SKSpriteNode?
    var rightWall: SKSpriteNode?
    var walls: [SKSpriteNode] = []
    
    var acid: SKSpriteNode?
    
    var lightNode: SKLightNode?
    let lightSwitch: Bool = false
    
    var heightLabel: SKLabelNode?
    
    let wallWidth: CGFloat = 35.0
    
    let baseColor: SKColor = SKColorWithRGB(170, 57, 57)
    let secondaryColor: SKColor = SKColorWithRGB(128, 21, 21)
    let shadowColor: SKColor = SKColorWithRGBA(0, 0, 0, 60)
    
    var correctingBody = true
    
    var spider: Spider?
    
    let levelHeight: CGFloat = 100.0
    var currentSpiderHeight: Int = 100
    var currentLevel = 1
    
    var acidAction: SKAction?
    
    let itemSize = CGSize(width: 30.0, height: 30.0)
    
    override func didMoveToView(view: SKView) {
        createSceneContents(view)
        
        spider = Spider(container: self)
        spider!.setupSpiderFor(35.0)
        
        let legPanRecognizer = UIPanGestureRecognizer(target: spider!, action:Selector("didRecognizeLegPan:"))
        view.addGestureRecognizer(legPanRecognizer)
        legPanRecognizer.delegate = self
        
        let bodyPanRecognizer = UIPanGestureRecognizer(target: spider!, action:Selector("hadleBodyPan:"))
        view.addGestureRecognizer(bodyPanRecognizer)
        bodyPanRecognizer.delegate = self
        
        startUpMyGravityPlayground(view)
        self.physicsWorld.contactDelegate = self
        
        startUpHearthburn()
    }
    
    func reloadScene() {
        var gameScene: GameScene = GameScene(size: self.size)
        let transition: SKTransition = SKTransition.fadeWithDuration(0.75)
        self.view?.presentScene(gameScene, transition: transition)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactBodies = sortContactBodiesByCategoryBitMask(contact.bodyA, b: contact.bodyB)
        
        if (contactBodies.firstBody.categoryBitMask & PhysicsCategory.Spider != 0) && (contactBodies.secondBody.categoryBitMask & PhysicsCategory.DroppedItem != 0) {
            droppedItemDidCollideWithSpider(contactBodies.firstBody.node as SKSpriteNode, item: contactBodies.secondBody.node as SKSpriteNode)
        }
        else if (contactBodies.firstBody.categoryBitMask & PhysicsCategory.Acid != 0) && (contactBodies.secondBody.categoryBitMask & PhysicsCategory.UsedItem != 0) {
            droppedItemDidReachAcid(contactBodies.firstBody.node as SKSpriteNode, item: contactBodies.secondBody.node as SKSpriteNode)
        }
        else if (contactBodies.firstBody.categoryBitMask & PhysicsCategory.Floor != 0) && ((contactBodies.secondBody.categoryBitMask & PhysicsCategory.DroppedItem != 0) || (contactBodies.secondBody.categoryBitMask & PhysicsCategory.UsedItem != 0)) {
            droppedItemDidReachFloor(contactBodies.firstBody.node, item: contactBodies.secondBody.node as SKSpriteNode)
        }
        else if (contactBodies.firstBody.categoryBitMask & PhysicsCategory.Spider != 0) && (contactBodies.secondBody.categoryBitMask & PhysicsCategory.Acid != 0) {
            gameOver()
        }
    }
    
    func sortContactBodiesByCategoryBitMask(a: SKPhysicsBody, b: SKPhysicsBody) -> (firstBody: SKPhysicsBody, secondBody: SKPhysicsBody) {
        if a.categoryBitMask < b.categoryBitMask {
            return (a,b)
        } else {
            return (b,a)
        }
    }
    
    func droppedItemDidCollideWithSpider (spider: SKSpriteNode, item: SKSpriteNode) {
        if let spidey = self.spider {
            item.physicsBody?.categoryBitMask = PhysicsCategory.UsedItem
            runAction(SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false))
            spidey.move(-60.0)
        }
    }
    
    func droppedItemDidReachFloor (floor: SKNode?, item: SKSpriteNode) {
        item.removeFromParent()
    }
    
    func droppedItemDidReachAcid (acid: SKSpriteNode, item: SKSpriteNode) {
        runAction(SKAction.playSoundFileNamed("plum.wav", waitForCompletion: false))
    }
    
    func gameOver() {
        let sound = SKAction.playSoundFileNamed("death.wav", waitForCompletion: true)
        let block = SKAction.runBlock { () -> Void in
            self.view!.paused = true
        }
        runAction(SKAction.sequence([sound, block]))
        
        let label = SKLabelNode(text: "Game over!")
        label.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        label.fontSize = 60
        label.zPosition = ZPosition.HUD.rawValue
        addChild(label)
        
        runAction(SKAction.afterDelay(1.0, runBlock: { () -> Void in
            self.reloadScene()
        }))
    }

    func startUpMyGravityPlayground(view: SKView) {
        self.physicsWorld.gravity = CGVectorMake(0.0, -1.0)
        
        let waitAction = SKAction.waitForDuration(5.0)
        let dropItemAction = SKAction.runBlock {
            self.createBalls(view)
        }
        
        let sequence = SKAction.sequence([waitAction, dropItemAction])
        
        runAction(SKAction.repeatActionForever(sequence))
    }
    
    func startUpHearthburn() {
        let waitAction = SKAction.waitForDuration(1.0)
        let moveAction = SKAction.moveBy(CGVector(dx: 0.0, dy: 50.0), duration: 1.0)
        let sequence = SKAction.sequence([waitAction, moveAction])
        
        acid?.runAction(SKAction.repeatActionForever(sequence))
        acidAction = waitAction
    }
    
    func createAcid(view: SKView) {
        let acidNode = SKSpriteNode(texture: SKTexture(imageNamed: "acid"), color: SKColor.clearColor(), size: CGSize(width: CGRectGetWidth(view.frame), height: CGRectGetHeight(view.frame)))
        acidNode.position = CGPoint(x: CGRectGetWidth(view.frame)/2.0, y: -(CGRectGetHeight(view.frame)/2.0 - acidInitialHeight - acidTransparentAreaHeight))
        acidNode.zPosition = ZPosition.Acid.rawValue
        acidNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: CGRectGetWidth(acidNode.frame), height: CGRectGetHeight(acidNode.frame) - acidTransparentAreaHeight*2))
        acidNode.physicsBody?.dynamic = false
        acidNode.physicsBody?.categoryBitMask = PhysicsCategory.Acid
        acidNode.physicsBody?.contactTestBitMask = PhysicsCategory.Spider | PhysicsCategory.UsedItem
        acidNode.physicsBody?.collisionBitMask = 0x0
        acidNode.lightingBitMask = LightingCategory.MainLightSource
        addChild(acidNode)
        acid = acidNode
        
        createAcidSurface(view, acidNode: acidNode)
    }
    
    func createAcidSurface(view: SKView, acidNode: SKSpriteNode) {
        var surfaceFrames: [SKTexture] = []
        let surfaceAnimatedAtlas = SKTextureAtlas(named: "AcidSurface")
        
        for i in 1...surfaceAnimatedAtlas.textureNames.count {
            let textureName = "acid_surface_0\(i)"
            let texture = surfaceAnimatedAtlas.textureNamed(textureName)
            surfaceFrames.append(texture)
        }
        
        let surfaceNode = SKSpriteNode(texture: surfaceFrames.first)
        surfaceNode.position = CGPoint(x: 0.0,y: 240)   // TODO: ?
        surfaceNode.lightingBitMask = LightingCategory.MainLightSource
        acidNode.addChild(surfaceNode)
        surfaceNode.bringToFront()  // TODO: ?
        
        surfaceNode.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(surfaceFrames, timePerFrame: 0.1)))
    }

    func createEsophagus(view: SKView) {
        let center = CGPoint(x: CGRectGetWidth(view.frame)/2.0, y: CGRectGetHeight(view.frame)/2.0)
        
        let background = SKSpriteNode(texture: SKTexture(imageNamed: "esophagus_surface"), size: view.frame.size)
        background.position = center
        background.zPosition = ZPosition.Background.rawValue
        background.lightingBitMask = LightingCategory.MainLightSource
        addChild(background)
        
        addWallAtPositon(center)
        createFloor()
    }
    
    func addWallAtPositon(pos: CGPoint) {
        let walls = SKSpriteNode(texture: SKTexture(imageNamed: "esophagus_walls"), color: SKColor.clearColor(), size: self.size)
        walls.position = pos
        walls.zPosition = ZPosition.Walls.rawValue
        walls.lightingBitMask = LightingCategory.MainLightSource
        self.walls.append(walls)
        
        createLeftWall(wallWidth, wallHeight: self.size.height, wall: walls)
        createRightWall(wallWidth, wallHeight: self.size.height, wall: walls)
        
        addChild(walls)
    }
    
    func createLeftWall(wallWidth: CGFloat, wallHeight: CGFloat, wall: SKSpriteNode) {
        let wallNode = createWallNode(wallWidth, wallHeight: wallHeight)
        wallNode.position = CGPoint(x: -wall.position.x + wallWidth/2.0, y: 0.0)
        wall.addChild(wallNode)
        leftWall = wallNode
    }
    
    func createRightWall(wallWidth: CGFloat, wallHeight: CGFloat, wall: SKSpriteNode) {
        let wallNode = createWallNode(wallWidth, wallHeight: wallHeight)
        wallNode.position = CGPoint(x: wall.position.x - wallWidth/2.0, y: 0.0)
        wall.addChild(wallNode)
        rightWall = wallNode
    }
    
    func createWallNode(wallWidth: CGFloat, wallHeight: CGFloat) -> SKSpriteNode {
        let node = SKSpriteNode(color: SKColor.clearColor(), size: CGSize(width: wallWidth, height: wallHeight))
        node.zPosition = ZPosition.Walls.rawValue
        node.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: -wallWidth/2.0, y: -wallHeight/2.0, width: wallWidth, height: wallHeight))
        node.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        node.lightingBitMask = LightingCategory.MainLightSource
        
        return node
    }
    
    func createFloor() {
        let floor = SKNode()
        let floorHeight = CGFloat(1.0)
        
        floor.position = CGPoint(x: self.size.width/2.0, y: -(itemSize.height + floorHeight/2.0))
        floor.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.size.width, height: floorHeight))
        floor.physicsBody?.dynamic = false
        floor.physicsBody?.categoryBitMask = PhysicsCategory.Floor
        floor.physicsBody?.collisionBitMask = PhysicsCategory.None
        floor.physicsBody?.contactTestBitMask = PhysicsCategory.DroppedItem | PhysicsCategory.UsedItem
        addChild(floor)
    }
    
    func createBalls(view: SKView) {
        let offsetFromWalls = CGFloat(10)
        let ballsDropPointOffset = CGFloat(100)
        let ballSize = itemSize
        
        let items = ["apple", "earthworm", "sausage"]
        let randomIndex = Int.random(min: 0, max: 2)
        
        let ball = SKSpriteNode(texture: SKTexture(imageNamed:items[randomIndex]), color: SKColor.clearColor(), size: ballSize)
        ball.position = CGPoint(x: CGFloat.random(min: wallWidth + offsetFromWalls, max: CGRectGetWidth(view.frame) - wallWidth - offsetFromWalls), y: CGRectGetHeight(view.frame) + ballsDropPointOffset)
        ball.zPosition = ZPosition.Items.rawValue
        addChild(ball)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballSize.width/2.0)
        ball.physicsBody?.allowsRotation = true
        ball.physicsBody?.categoryBitMask = PhysicsCategory.DroppedItem | PhysicsCategory.UsedItem
        ball.physicsBody?.restitution = 0.8
        ball.physicsBody?.collisionBitMask = PhysicsCategory.Spider | PhysicsCategory.Wall
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.Spider | PhysicsCategory.Acid
        ball.lightingBitMask = LightingCategory.MainLightSource
    }
    
    func createItem(view: SKView) {
        let offsetFromWalls = CGFloat(10)
        let itemDropPointOffset = CGFloat(100)
        
        let item = Item(size: itemSize)
        item.sprite.position = CGPoint(x: CGFloat.random(min: wallWidth + offsetFromWalls, max: CGRectGetWidth(view.frame) - wallWidth - offsetFromWalls), y: CGRectGetHeight(view.frame) + itemDropPointOffset)
        addChild(item.sprite)
    }
    
    func createSceneContents(view: SKView) {
        createEsophagus(view)
        createAcid(view)
        
        createHeightLabel(view)
        updateHeightLabel(currentLevel)
        
        if lightSwitch {
            letThereBeLight(view)
        }
    }
    
    func createHeightLabel(view: SKView) {
        let label = SKLabelNode(text: "\(currentSpiderHeight)")
        label.position = CGPoint(x: view.frame.size.width - 30, y: 10)
        label.fontName = "HelveticaNeue-Bold"
        label.fontSize = 30
        label.fontColor = SKColor.orangeColor()
        label.zPosition = ZPosition.HUD.rawValue
        addChild(label)
        heightLabel = label
    }

    func updateHeightLabel(value: Int) {
        heightLabel?.text = "\(value)"
        acidAction?.duration = 1.0
    }
    
    func letThereBeLight(view: SKView) {
        let light = SKLightNode()
        let lightNodeOffset = CGFloat(50.0)
        light.position = CGPoint(x: CGRectGetWidth(view.frame)/2.0, y: CGRectGetHeight(view.frame) + lightNodeOffset)
        light.categoryBitMask = LightingCategory.MainLightSource
        light.falloff = 0.5
        addChild(light)
        lightNode = light
    }
    
    override func update(currentTime: NSTimeInterval) {
        if lastUpdate == 0 {
            lastUpdate = currentTime
        }
        
        let delta = currentTime - lastUpdate
        
        if let spider = self.spider {
            if spider.body.position.y > 0.85 * self.size.height && !spider.bodyPanning {
                bodyCorrected(CGPointMake(0, 200))
                updateHeightLabel(++currentLevel)
            }
            
            spider.update(currentTime - lastUpdate)
            
        }
        
        lastUpdate = currentTime
    }
    
    func bodyCorrected(delta: CGPoint) {
        acid?.position -= delta
        
        if let wall = walls.last {
            if wall.position.y <= (self.size.height / 2) + 200 {
                addWallAtPositon(CGPointMake(self.size.width / 2, self.size.height + wall.position.y))
            }
        }
        
        
        for wall in walls {
            wall.position -= delta
        }
        
        spider?.move(-delta.y)
    }
}
