//
//  Utility.swift
//  Pyramids
//
//  Created by Naheed Shamim on 31/10/17.
//  Copyright © 2017 Naheed Shamim. All rights reserved.
//

import UIKit

class Utility: NSObject {
    
    class func saveHighScore(score:Int)
    {
        UserDefaults.standard.set(score, forKey: "maxScore")  //Integer
    }
    
    class func getHighScore() -> Int?
    {
        return UserDefaults.standard.integer(forKey: "maxScore")
    }
    
    class func showWithZoomAnim(view:UIView)
    {
        view.transform = CGAffineTransform(scaleX: 0.1,y: 0.1)
        
        UIView.animate(withDuration: 0.2, animations: {
            view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    class func showZoomOutIn(view:UIView, scaleFactor:CGFloat)
    {
        view.transform = CGAffineTransform(scaleX: scaleFactor,y: scaleFactor)
        
        UIView.animate(withDuration: 0.4, animations: {
            view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
}
