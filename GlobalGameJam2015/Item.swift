//
//  Item.swift
//  GlobalGameJam2015
//
//  Created by screenname on 29.01.2015.
//  Copyright (c) 2015 Tomasz Bąk. All rights reserved.
//

import SpriteKit

class Item: Printable {
    
    var sprite: SKSpriteNode
    let type: ItemType
    let size: CGSize
    
    init(size: CGSize) {
        self.type = ItemType.random()
        self.size = size
        self.sprite = SKSpriteNode(texture: SKTexture(imageNamed:self.type.name), color: SKColor.clearColor(), size: self.size)
        
        setUpItemNode()
        setUpPhysicsBody()
    }
    
    private func setUpItemNode() {
        sprite.zPosition = ZPosition.Items.rawValue
        sprite.lightingBitMask = LightingCategory.MainLightSource
    }

    private func setUpPhysicsBody() {
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: size.width/2.0)
        sprite.physicsBody?.allowsRotation = true
        sprite.physicsBody?.categoryBitMask = PhysicsCategory.DroppedItem | PhysicsCategory.UsedItem
        sprite.physicsBody?.restitution = 0.8
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.Spider | PhysicsCategory.Wall
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.Spider | PhysicsCategory.Acid
    }
    
    var description: String {
        return "type: \(type)"
    }
}

enum ItemType: Int, Printable {
    case Apple, Earthwarm, Sausage
    
    var names: [String] {
        return ["apple", "earthworm", "sausage"]
    }
    
    var name: String {
        return names[rawValue]
    }
    
    static func random() -> ItemType {
        return ItemType(rawValue: Int.random(3))!
    }
    
    var description: String {
        return name
    }
}
