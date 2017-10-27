
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
    @IBOutlet weak var mGameView: GameView!
    
    override func viewDidLoad()
    {
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
        mGameView.stopGame()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pauseAction(_ sender: Any)
    {
        mGameView.pauseGame()
    }
    
    @IBAction func levelChange(_ sender: Any)
    {
        mGameView.setLevel(level: 2)
    }
    func updateScore(score: Int)
    {
        scoreLbl.text = "\(score)"
    }
}
