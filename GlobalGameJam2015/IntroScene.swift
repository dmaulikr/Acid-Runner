//
//  IntroScene.swift
//  GlobalGameJam2015
//
//  Created by Tomasz Bąk on 25.01.2015.
//  Copyright (c) 2015 Tomasz Bąk. All rights reserved.
//

import SpriteKit
import AVFoundation

class IntroScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(color: UIColor.blackColor(), size: self.size)
        background.position = CGPointMake(self.size.width / 2 , self.size.height / 2 )
        
        let firstSentence1 = SKLabelNode(text: "Every year we swallow")
        firstSentence1.position += CGPointMake(0, 30)
        firstSentence1.alpha = 0
        firstSentence1.fontName = "Futura"
        firstSentence1.fontSize = 20
        background.addChild(firstSentence1)
        
        let firstSentence2 = SKLabelNode(text: "8 spiders while we sleep.")
        firstSentence2.position -= CGPointMake(0, 0)
        firstSentence2.alpha = 0
        firstSentence2.fontName = "Futura"
        firstSentence2.fontSize = 20
        background.addChild(firstSentence2)
        
        let secondSentence = SKLabelNode(text: "How many of them get out?")
        secondSentence.position -= CGPointMake(0, 50)
        secondSentence.alpha = 0
        secondSentence.fontName = "Futura"
        secondSentence.fontSize = 20
        background.addChild(secondSentence)
        
        addChild(background)
        let fadeIn = SKAction.fadeInWithDuration(0.5)
        let wait2sec = SKAction.waitForDuration(2)
        let video = SKAction.runBlock { () -> Void in
            firstSentence1.alpha = 0
            firstSentence2.alpha = 0
            secondSentence.alpha = 0
            self.showVideo()
        }
        
        firstSentence1.runAction(SKAction.sequence([fadeIn]))
        firstSentence2.runAction(SKAction.sequence([fadeIn]))
        secondSentence.runAction(SKAction.sequence([wait2sec, fadeIn, wait2sec, video]))
    }
    
    func showVideo() {
        let introUrl = NSBundle.mainBundle().URLForResource("intro", withExtension: "mp4")
        
        if let url = introUrl {
            let player = AVPlayer.playerWithURL(url) as AVPlayer
            let node = SKVideoNode(AVPlayer: player)
            node.position = CGPointMake(self.size.width / 2 , self.size.height / 2 )
            node.size = self.size
            addChild(node)
            node.play()
            
            let acid = SKLabelNode(text:"ACID")
            acid.fontName = "Futura"
            acid.fontSize = 90
            acid.fontColor = UIColor.greenColor()
            acid.position = CGPointMake(self.size.width / 2, self.size.height / 2 + 30)
            acid.alpha = 0
            
            let runner = SKLabelNode(text:"RUNNER")
            runner.fontName = "Futura"
            runner.fontSize = 50
            runner.fontColor = UIColor.whiteColor()
            runner.position = CGPointMake(self.size.width / 2, self.size.height / 2 - 20)
            runner.alpha = 0;
            
            let wait = SKAction.waitForDuration(5)
            let block = SKAction.runBlock({ () -> Void in
                self.addChild(acid)
                self.addChild(runner)
                acid.runAction(SKAction.fadeInWithDuration(0.5))
                runner.runAction(SKAction.fadeInWithDuration(1.5))
            })
            
            let block2 = SKAction.runBlock({ () -> Void in
                if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
                    
                    if let skView = self.view {
                        scene.scaleMode = .AspectFill
                        skView.presentScene(scene)
                    }
                    
                    
                }
            })
            let wait2 = SKAction.waitForDuration(2)
            runAction(SKAction.sequence([wait, block, wait, block2]))
        }
    }

   
}
