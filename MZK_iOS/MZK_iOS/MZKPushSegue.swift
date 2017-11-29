//
//  MZKPushSegue.swift
//  MZK_iOS
//
//  Created by OndrejVyhlidal on 21/11/2017.
//  Copyright © 2017 Ondrej Vyhlidal. All rights reserved.
//

import UIKit

class MZKPushSegue: UIStoryboardSegue {
    
    override func perform() {
        animatePush()
    }

    func animatePush() {
        let fromVC = self.source
        let toVC = self.destination
        
        let xToVCStart = fromVC.view.frame.size.width
        
        let startFrame = CGRect(x: xToVCStart, y: 0, width: toVC.view.bounds.size.width, height: toVC.view.bounds.size.height)
        // set start frame
        toVC.view.frame = startFrame
        
        // get end frame
         let endFrame = fromVC.view.frame
        // animate move of the destination controller
        fromVC.present(toVC, animated: false, completion: {
            UIView.animate(withDuration: 5.0, delay: 0, options: .curveEaseInOut, animations: {
                toVC.view.layoutIfNeeded()
                toVC.view.frame = endFrame
            }) { (finished) in
                
            }
        })
        
        
        
        
      
//        UIView.animate(withDuration: 1.0, animations: {
//            toVC.view.layoutIfNeeded()
//            toVC.view.frame = endFrame
//        }) { (finished) in
//
//            fromVC.present(toVC, animated: false, completion: nil)
//        }
        
    }
}
