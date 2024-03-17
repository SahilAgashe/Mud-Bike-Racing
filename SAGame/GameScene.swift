//
//  GameScene.swift
//  SAGame
//
//  Created by SAHIL AMRUT AGASHE on 15/03/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: - Property
    let player = SKSpriteNode(imageNamed: "player-motorbike")
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    let music = SKAudioNode(fileNamed: "cyborg-ninja")
    var touchingPlayer = false
    var gameTimer: Timer?
    
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
    // MARK: - Override
    
    /// this method is called when your game scene is ready to run
    override func didMove(to view: SKView) {
        
        scoreLabel.zPosition = 2
        scoreLabel.position.y = 210
        addChild(scoreLabel)
        score = 0
        
        let background = SKSpriteNode(imageNamed: "road")
        background.zPosition = -1
        addChild(background)
        
        if let particles = SKEmitterNode(fileNamed: "Mud") {
            particles.advanceSimulationTime(10)
            particles.position.x = 512
            addChild(particles)
        }
        
        player.position.x = -250
        player.zPosition = 1
        addChild(player)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = 1
        
        physicsWorld.contactDelegate = self
        
        addChild(music)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let tappedNodes = nodes(at: location)
        if tappedNodes.contains(player) {
            touchingPlayer = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard touchingPlayer else { return }
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        player.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingPlayer = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // if you want increase score according how long staying alive
        //score += 1
        
        // horizontal restrictions
        if player.position.x < -300 {
            player.position.x = -300
        } else if player.position.x > 300 {
            player.position.x = 300
        }
        
        // vertical restrictions
        if player.position.y < -300 {
            player.position.y = -300
        } else if player.position.y > 300 {
            player.position.y = 300
        }
    }
    
    // MARK: - Selectors
    
    @objc private func createEnemy() {
        let randomDistribution = GKRandomDistribution(lowestValue: -350, highestValue: 350)
        let sprite = SKSpriteNode(imageNamed: "car")
        // asteroid can also be enemy
        
        sprite.position = CGPoint(x: 1000, y: randomDistribution.nextInt())
        sprite.name = "enemy"
        sprite.zPosition = 1
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.affectedByGravity = false
        
        sprite.physicsBody?.contactTestBitMask = 1
        sprite.physicsBody?.categoryBitMask = 0
        
        // Also create coin so player can collect it!
        createBonus()
    }
    
    // MARK: - Helpers
    
    private func playerHit(_ node: SKNode) {
        if node.name == "bonus" {
            score += 100
            node.removeFromParent()
            return
        }
        
        if let particles = SKEmitterNode(fileNamed: "BurningFire") {
            particles.position = player.position
            particles.zPosition = 3
            addChild(particles)
        }
        
        music.removeFromParent()
        player.removeFromParent()
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver-1")
        gameOver.zPosition = 10 // default zPostion is 0
        addChild(gameOver)

        let sound = SKAction.playSoundFileNamed("explosion", waitForCompletion: false)
        run(sound)
        
    }
    
    private func createBonus() {
        let randomDistribution = GKRandomDistribution(lowestValue: -350, highestValue: 350)
        let sprite = SKSpriteNode(imageNamed: "coin")
        
        sprite.position = CGPoint(x: 1000, y: randomDistribution.nextInt())
        sprite.name = "bonus"
        sprite.zPosition = 1
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.affectedByGravity = false
        
        sprite.physicsBody?.contactTestBitMask = 1
        sprite.physicsBody?.categoryBitMask = 0
        sprite.physicsBody?.collisionBitMask = 0
    }
}

// MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerHit(nodeB)
        } else {
            playerHit(nodeA)
        }
    }
    
}
