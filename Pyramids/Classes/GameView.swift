//
//  GameView.swift
//  Pyramids
//
//  Created by Naheed Shamim on 27/10/17.
//  Copyright © 2017 Naheed Shamim. All rights reserved.
//

import UIKit
import SceneKit

protocol GameScoreDelegate : class
{
    func updateScore(score:Int)
    func updateLives(life:Int)
}

class GameView: SCNView,SCNSceneRendererDelegate
{
    weak var gameView:SCNView!
    var gameScene:SCNScene!
    var cameraNode:SCNNode!
    
    var startTime = TimeInterval()
    var targetCreationTime:TimeInterval = 0
    var levelPoints = 1
    var score = 0
    var isGamePaused : Bool = false
    var isGameOver : Bool = false
    var lives = 3
    var level = 0
    
    weak var scoreDelegate : GameScoreDelegate?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setupGame()
    }
    
    init()
    {
        super.init(frame: CGRect(x: 0, y: hudHieght, width: screenWidth, height: screenHeight),
                   options: nil)
        setupGame()
    }
    
    deinit
    {
        gameView = nil
        gameScene = nil
        cameraNode = nil
    }
    
    func setupGame()
    {
        initView()
        initScene()
        initCamera()
    }
    
    func initView()
    {
        gameView = self
        gameView.backgroundColor = UIColor.black
//        gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
        
        gameView.delegate = self
    }
    
    func initScene (){
        gameScene = SCNScene()
        gameView.scene = gameScene
        
        gameView.isPlaying = true
    }
    
    func initCamera()
    {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y:5, z: 10)
        
        gameScene.rootNode.addChildNode(cameraNode)
    }
    
    func setLevel(level:Int)
    {
        levelPoints = level
    }
    
    func iGamePaused() -> Bool
    {
        return (gameView.scene?.isPaused)!
    }
    
    func pauseGame()
    {
        gameView.scene?.isPaused = !(gameView.scene?.isPaused)!
        isGamePaused = (gameView.scene?.isPaused)!
        gameView.isUserInteractionEnabled = !isGamePaused
    }
    
    func stopGame()
    {
        gameView.stop(self)
    }
    
    func updateHighScore()
    {
        if let maxScore = Utility.getHighScore()
        {
            if self.score > maxScore
            {
                Utility.saveHighScore(score: self.score)
            }
        }
    }
    
    func isLifePresent() -> Bool
    {
        if self.lives < 1{
            return false
        }
        
        return true
    }

    func gameOver()
    {
        self.isGameOver = true
        updateHighScore()
        stopGame()
        
        DispatchQueue.main.async
        {
            GameOverView.sharedInstance.showScore(score: self.score, overView: self)
        }
    }
    
    func getGeometry() -> Array<SCNGeometry>
    {
        var geometryArray : Array<SCNGeometry> = []
        geometryArray.append(SCNPyramid(width: 1, height: 1, length: 1))
        //        geometryArray.append(SCNSphere(radius: 0.5))
        geometryArray.append(SCNCone(topRadius: 0, bottomRadius: 0.5, height: 1))
        
        geometryArray.append(SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
        
        return geometryArray
    }
    
    func createTarget()
    {
        let randomIndex:Int = Int(arc4random_uniform(UInt32(getGeometry().count)))
        let randomGeometry = getGeometry()[randomIndex]
        
        let randomColor = arc4random_uniform(2) == 0 ? UIColor.green : UIColor.red
        randomGeometry.materials.first?.diffuse.contents = randomColor
        
        let geometryNode = SCNNode(geometry: randomGeometry)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        if randomColor == UIColor.green //&& randomGeometry.isKind(of: SCNPyramid())
        {
            geometryNode.name = "friend"
        }
        else
        {
            geometryNode.name = "enemy"
        }
        
        gameScene.rootNode.addChildNode(geometryNode)

        setForceOnNode(node: geometryNode)
    }
    
    func setForceOnNode(node:SCNNode)
    {
        var yDirection : Float = 0
        var position : Float = 0
        
        switch self.level
        {
            case 1 :    yDirection = 12
                        position = 0.05
                    break
            case 2 :    yDirection = 15
                        position = 0.10
                    break
            case 3 :    yDirection = 16
                        position = 0.15
                    break
            case 3 :    yDirection = 18
                        position = 0.20
                    break
            case 4 :    yDirection = 20
                        position = 0.35
                break
                default : yDirection = 15
        }
        
        let randomDirection:Float = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        let force = SCNVector3(x: randomDirection, y: yDirection, z: 0)
        
        node.physicsBody?.applyForce(force, at: SCNVector3(x: position, y: position, z: position), asImpulse: true)
    }
    
    func setTargetCreationTime(time:TimeInterval)
    {
        var timeInterval : Double = 0
        
        switch self.level
        {
        case 1 : timeInterval = 0.6
            break
        case 2 : timeInterval = 0.6
            break
        case 3 : timeInterval = 0.5
            break
        case 4 : timeInterval = 0.4
            break
        default : timeInterval = 0.6
        }
        
        self.targetCreationTime = time + timeInterval
    }
    
    func increaseLevel()
    {
        self.level = self.level + 1
        self.lives = self.lives + 1
        
        if self.level > 4 {
            self.level = 4
        }
        
        self.lives = self.lives > 5 ? 5 : self.lives
        
    }
    
    //MARK: - SCNSceneRenderer Delegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        print("\(time)")
     
        if(time - self.startTime > 15 )
        {
            self.startTime = time
            increaseLevel()
            //increaseLevel
        }
        
        if !isGamePaused
        {
            if isLifePresent()
            {
                if time > self.targetCreationTime
                {
                    createTarget()
                    setTargetCreationTime(time: time)
//                    self.targetCreationTime = time + 0.6
                }
            }
            else
            {
                if !isGameOver
                {
                    gameOver()
                }
            }
            cleanUp()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch = touches.first!
        let location = touch.location(in: gameView)
        let hitList = gameView.hitTest(location, options: nil)
        
        if isLifePresent()
        {
            if let hitObject = hitList.first
            {
                let node = hitObject.node
                
                if node.name == "friend"
                {
                    self.score = self.score + levelPoints
                    node.removeFromParentNode()
                    self.gameView.backgroundColor = UIColor.black
                }
                else
                {
                    self.lives = self.lives - 1
                    self.score = (score - levelPoints) < 0 ? 0 : (score - levelPoints)
                    
                    node.removeFromParentNode()
                    self.gameView.backgroundColor = UIColor.red
                }
            
                print("\(score)")
                self.scoreDelegate?.updateScore(score: self.score)
                self.scoreDelegate?.updateLives(life: self.lives)
            }
        }
    }
    
    func cleanUp ()
    {
        for node in gameScene.rootNode.childNodes
        {   
            if node.presentation.position.y < 0
            {
                if isLifePresent()
                {
                    if node.name == "friend"
                    {
                        self.lives = self.lives - 1
                        self.score = (score - levelPoints) < 0 ? 0 : (score - levelPoints)
                        print("\(score)")
                        self.scoreDelegate?.updateScore(score: self.score)
                        self.scoreDelegate?.updateLives(life: self.lives)
                    }
                    node.removeFromParentNode()
                }
                else
                {
                    if !isGameOver
                    {
                        gameOver()
                    }
                }
            }
        }
    }
}
