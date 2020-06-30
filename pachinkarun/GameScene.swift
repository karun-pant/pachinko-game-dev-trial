//
//  GameScene.swift
//  pachinkarun
//
//  Created by Karun Pant on 21/06/20.
//  Copyright © 2020 Karun Pant. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    enum ColoredBall: Int, CaseIterable {
        case red, yellow, cyan, blue, green, gray, purple
        
        private var ballImageName: String {
            switch self {
            case .red:
                return "ballRed"
            case .yellow:
                return "ballYellow"
            case .cyan:
                return "ballCyan"
            case .blue:
                return "ballBlue"
            case .green:
                return "ballGreen"
            case .gray:
                return "ballGrey"
            case .purple:
                return "ballPurple"
            }
        }
        static var randomizedBallName: String {
            let randomBallId = Int.random(in: 0..<ColoredBall.allCases.count)
            return ColoredBall(rawValue: randomBallId)?.ballImageName ?? "ballRed"
        }
    }
    lazy var ballStartThresholdY = self.frame.size.height * 3 / 4
    
    let scoreLabel: SKLabelNode = {
        let scoreLabel: SKLabelNode = .init(fontNamed: "Chalkduster")
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        scoreLabel.text = "Score: 0"
        return scoreLabel
    }()
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    let editLabel: SKLabelNode = {
        let editLabel: SKLabelNode = .init(fontNamed: "Chalkduster")
        editLabel.horizontalAlignmentMode = .right
        editLabel.position = CGPoint(x: 120, y: 700)
        editLabel.text = "Edit"
        return editLabel
    }()
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func sceneDidLoad() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        addSlots()
        addBouncers()
        addStartLine()
        addChild(scoreLabel)
        addChild(editLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                addObstacle(at: location)
            } else {
                dropBall(fromlocation: location)
            }
        }
    }
    
    func addObstacle(at position: CGPoint) {
        // Challanges:
        // 1. Add obstacle in  the start of the game by  default using some algo.
        // 2. Give players a limit of five balls, then remove obstacle boxes when they are hit. Can they clear all the pins with just five balls? You could make it so that landing on a green slot gets them an extra ball.
        
        guard position.y < ballStartThresholdY, position.y > 150 else {
            return
        }
        let size = CGSize(width: Int.random(in: 50...128), height: 16)
        let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
        box.zRotation = CGFloat.random(in: 0...3)
        box.position = position
        box.physicsBody =  SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic = false
        box.physicsBody?.contactTestBitMask = 1
        box.name = "obstacle"
        addChild(box)
    }
    func dropBall(fromlocation location: CGPoint) {
        guard location.y > ballStartThresholdY else {
            return
        }
        let ball = SKSpriteNode(imageNamed: ColoredBall.randomizedBallName)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.restitution = 0.4
        ball.position = location
        ball.name = "ball"
        ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
        addChild(ball)
    }
    
    func addStartLine() {
        let line = SKShapeNode()
        let shapePath = CGMutablePath()
        shapePath.move(to: CGPoint(x: 0, y: ballStartThresholdY - 10))
        shapePath.addLine(to: CGPoint(x: self.frame.size.width, y: ballStartThresholdY - 10))
        line.strokeColor = .white
        line.lineWidth = 5
        line.glowWidth = 2
        line.path = shapePath
        addChild(line)
    }
    func addBouncers() {
        var posXMultiplier: CGFloat = 0
        while posXMultiplier <= 1 {
            let bouncer = SKSpriteNode(imageNamed: "bouncer")
            bouncer.position = CGPoint(x: self.frame.size.width * CGFloat(posXMultiplier), y: 0)
            bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width/2)
            bouncer.physicsBody?.isDynamic = false
            addChild(bouncer)
            posXMultiplier += 0.25
        }
    }
    
    func addSlots() {
        var posXMultiplier: CGFloat = 0
        var isGoodSlot = true
        while posXMultiplier < 1 {
            let slotBaseName = isGoodSlot ? "good" : "bad"
            let slotBaseImage = isGoodSlot ? "slotBaseGood" : "slotBaseBad"
            let bouncerPosition = CGPoint(x: self.frame.size.width * CGFloat(posXMultiplier), y: 0)
            let bouncer = SKSpriteNode(imageNamed: "bouncer")
            let slotPosition = CGPoint(x: bouncerPosition.x + bouncer.size.width, y: 0)
            let slotBase: SKSpriteNode = SKSpriteNode(imageNamed: slotBaseImage)
            slotBase.name = slotBaseName
            slotBase.position = slotPosition
            slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
            slotBase.physicsBody?.isDynamic = false
            addChild(slotBase)

            let slotGlowImage = isGoodSlot ? "slotGlowGood" : "slotGlowBad"
            let slotGlow: SKSpriteNode = SKSpriteNode(imageNamed: slotGlowImage)
            slotGlow.position = slotPosition
            addChild(slotGlow)
            
            let spin = SKAction.rotate(byAngle: .pi, duration: 10)
            let spinForever = SKAction.repeatForever(spin)
            slotGlow.run(spinForever)
            
            isGoodSlot.toggle()
            posXMultiplier += 0.25
        }
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroyBall(ball)
            score += 1
        } else if object.name == "bad" {
            destroyBall(ball)
            score -= 1
        }
    }
    func destroyBall(_ ball: SKNode) {
        ball.removeFromParent()
    }
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node,
            let  nodeB = contact.bodyB.node else {
            return
        }
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    override func update(_ currentTime: TimeInterval) {
        
    }
}
