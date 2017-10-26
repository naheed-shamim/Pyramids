//
//  GameController.swift
//  Pyramids
//
//  Created by Naheed Shamim on 25/10/17.
//  Copyright © 2017 Naheed Shamim. All rights reserved.
//

import UIKit
import SceneKit

protocol GameScoreDelegate : class {
    func updateScore(score:Int)
}

class GameController: SCNView,SCNSceneRendererDelegate {
    
    var gameView:SCNView!
    var gameScene:SCNScene!
    var cameraNode:SCNNode!
    var targetCreationTime:TimeInterval = 0
    
    var levelPoints = 0
    var score = 0
    var isGamePaused : Bool = false
    
    weak var scoreDelegate : GameScoreDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGame()
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height),options: nil)
            setupGame()
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
        gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
        
        gameView.delegate = self
    }
    
    func initScene (){
        gameScene = SCNScene()
        gameView.scene = gameScene
        
        gameView.isPlaying = true
    }
    
    func initCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        cameraNode.position = SCNVector3(x: 0, y:5, z: 10)
        
        gameScene.rootNode.addChildNode(cameraNode)
    }
    
    func createTarget() {
        
        let geometry:SCNGeometry = SCNPyramid(width: 1, height: 1, length: 1)
        
        let randomColor = arc4random_uniform(2) == 0 ? UIColor.green : UIColor.red
        geometry.materials.first?.diffuse.contents = randomColor
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        if randomColor == UIColor.green
        {
            geometryNode.name = "friend"
        }
        else
        {
            geometryNode.name = "enemy"
        }
        
        gameScene.rootNode.addChildNode(geometryNode)        
        
        let randomDirection:Float = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        let force = SCNVector3(x: randomDirection, y: 15, z: 0)
        
        geometryNode.physicsBody?.applyForce(force, at: SCNVector3(x: 0.05, y: 0.05, z: 0.05), asImpulse: true)
    }
    
    func pauseGame()
    {
        gameView.scene?.isPaused = !(gameView.scene?.isPaused)!
        isGamePaused = (gameView.scene?.isPaused)!
        gameView.isUserInteractionEnabled = !isGamePaused
    }
    
    func getScore() -> String!
    {
        return "\(score)"        
    }
    
    //MARK: - SCNSceneRenderer Delegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if !isGamePaused
        {
            if time > targetCreationTime {
                createTarget()
                targetCreationTime = time + 0.6
        }
        cleanUp()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch = touches.first!
        let location = touch.location(in: gameView)
        let hitList = gameView.hitTest(location, options: nil)
        
        if let hitObject = hitList.first {
            let node = hitObject.node
            
            if node.name == "friend" {
                
                levelPoints = 1
                
                node.removeFromParentNode()
                self.gameView.backgroundColor = UIColor.black
            }
            else
            {
                levelPoints = -1
                
                node.removeFromParentNode()
                self.gameView.backgroundColor = UIColor.red
            }
            
            score = score + levelPoints
            print("\(score)")
            scoreDelegate?.updateScore(score: score)
        }
    }
    
    func cleanUp () {
        for node in gameScene.rootNode.childNodes {
            if node.presentation.position.y < -1 {
                node.removeFromParentNode()
            }
        }
    }
}
