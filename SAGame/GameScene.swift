//
//  GameScene.swift
//  SAGame
//
//  Created by SAHIL AMRUT AGASHE on 15/03/24.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    
    let player = SKSpriteNode(imageNamed: "player-motorbike")
    let motionManager = CMMotionManager()
    
    /// this method is called when your game scene is ready to run
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "road")
        background.zPosition = -1
        addChild(background)
        
        if let particles = SKEmitterNode(fileNamed: "Mud") {
            particles.advanceSimulationTime(10)
            particles.position.x = 512
            addChild(particles)
        }
        
        player.position.x = 0
        player.zPosition = 1
        addChild(player)
        
        motionManager.startAccelerometerUpdates()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if let accelerometerData = motionManager.accelerometerData
        {
            
            let changeX = CGFloat(accelerometerData.acceleration.y) * 100
            let changeY = CGFloat(accelerometerData.acceleration.x) * 100
            
            player.position.x -= changeX
            player.position.y += changeY
        }
    }
}
