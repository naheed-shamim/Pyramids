//
//  MainViewController.swift
//  Pyramids
//
//  Created by Naheed Shamim on 24/10/17.
//  Copyright © 2017 Naheed Shamim. All rights reserved.
//

import UIKit
import SceneKit

class MainViewController: UIViewController, GameScoreDelegate {
   
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var mGameView: GameController!
    
//    @IBOutlet weak var gameView: UIView!
    var gameController:GameController! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mGameView.scoreDelegate = self
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func closeGameAction(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
   
    @IBAction func pauseAction(_ sender: Any) {
//        gameController.pauseGame()
        mGameView.pauseGame()
    }
    
    func updateScore(score: Int)
    {
        scoreLbl.text = "\(score)"
    }
}
