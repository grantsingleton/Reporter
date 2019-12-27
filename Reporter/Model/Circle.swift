//
//  Circle.swift
//  shapes
//
//  Created by Grant Singleton on 11/28/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit

class Circle: ShapeView {
    
    override func draw(_ rectangle: CGRect) {
        
        let insetRectangle = rectangle.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        
        let circlePath = UIBezierPath(ovalIn: insetRectangle)
        
        let circleLayer = CAShapeLayer()
        circleLayer.strokeColor = UIColor.red.cgColor
        circleLayer.lineWidth = self.lineWidth
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(circleLayer)
        
    }
}
