//
//  Balloon.swift
//  kids-joy-center
//
//  Created by Cony Lee on 3/29/22.
//

import UIKit

class Balloon: UIImageView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.layer.presentation() != nil {
            let pres = self.layer.presentation()!
            let suppt = self.convert(point, to: self.superview!)
            let prespt = self.superview!.layer.convert(suppt, to: pres)
            
            return super.hitTest(prespt, with: event)
        }
        return nil
    }
}
