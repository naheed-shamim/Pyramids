//
//  GameOver.swift
//  Pyramids
//
//  Created by Naheed Shamim on 31/10/17.
//  Copyright © 2017 Naheed Shamim. All rights reserved.
//

import UIKit

class GameOverView: UIView
{
    static let sharedInstance = GameOverView()
    
    var backgroundView: UIView
    var scoreLabel: UILabel
    
    let margin:CGFloat = 10
    let viewSize:CGFloat = 200
    
    private init()
    {
        backgroundView = UIView(frame: CGRect(x: margin, y: margin, width: viewSize-2*margin, height: viewSize-2*margin))
        
        scoreLabel = UILabel(frame: CGRect(x: (viewSize-margin)/2, y: margin+100, width: 50, height: 21))
        scoreLabel.text = "0"
        
        super.init(frame: CGRect(x: 0, y: 0, width: viewSize, height: viewSize))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showScore(score: Int, overView view: UIView)
    {
        self.backgroundColor = UIColor.white
        backgroundView.backgroundColor = UIColor.black
        
        self.center = CGPoint(x: view.center.x, y: view.center.y)
        
        let centreView = viewSize/2
        
        let gameOverLbl = UILabel(frame: CGRect(x: centreView-40, y: centreView-30, width: 100, height: 21))
        gameOverLbl.text = "Game Over"
        gameOverLbl.textColor = UIColor.white
        
        let yourScoreLbl = UILabel(frame: CGRect(x: centreView-40, y: centreView-10, width: 100, height: 21))
        yourScoreLbl.text = "Your Score"
        yourScoreLbl.textColor = UIColor.white
        
        self.scoreLabel.textColor = UIColor.white
        self.scoreLabel.text = "\(score)"
        
        self.addSubview(backgroundView)
        self.addSubview(gameOverLbl)
        self.addSubview(yourScoreLbl)
        self.addSubview(scoreLabel)
        
        view.addSubview(self)
        Utility.showWithZoomAnim(view: self)
    }
}
