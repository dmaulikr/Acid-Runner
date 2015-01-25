//
//  GameViewController.swift
//  GlobalGameJam2015
//
//  Created by Tomasz Bąk on 23.01.2015.
//  Copyright (c) 2015 Tomasz Bąk. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = IntroScene(fileNamed: "GameScene")
        
        let skView = self.view as SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
    }
    
    // MARK: Status bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: View rotation

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
}
