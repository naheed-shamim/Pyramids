//
//  MainViewController.swift
//  Pyramids
//
//  Created by Naheed Shamim on 24/10/17.
//  Copyright © 2017 Naheed Shamim. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, GameScoreDelegate {
   
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var mGameView: GameController!    

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
    
    @IBAction func closeGameAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
//        mGameView.pauseGame()
    }
    
   
    @IBAction func pauseAction(_ sender: Any) {
        mGameView.pauseGame()
    }
    
    func updateScore(score: Int)
    {
        scoreLbl.text = "\(score)"
    }
}
