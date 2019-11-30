//
//  ShapeView.swift
//  shapes
//
//  Created by Grant Singleton on 11/21/19.
//  Copyright © 2019 Grant Singleton. All rights reserved.
//

import UIKit

class ShapeView: UIView {
    
    //MARK: Properties
    let size: CGFloat = 200.0
    let lineWidth: CGFloat = 3
    
    init(origin: CGPoint) {
        
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: size, height: size))
        
        // Set properties of the shape
        self.center = origin
        self.backgroundColor = UIColor.clear
        
        initGestureRecognizers()
    }
    
    // necessary boilerplate to avoid errors
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rectangle: CGRect) {
        //Overidden in Subclasses
    }
    
    //MARK: Actions
    
    func initGestureRecognizers() {
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector(("didPan:")))
        addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: Selector(("didPinch:")))
        addGestureRecognizer(pinchGestureRecognizer)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: Selector(("didRotate:")))
        addGestureRecognizer(rotationGestureRecognizer)
    }
    
    
    @IBAction func didPan(_ sender: UIPanGestureRecognizer) {
        
        self.superview!.bringSubviewToFront(self)
        
        var translation = sender.translation(in: self)
                       
        translation = translation.applying(self.transform)
        
        self.center.x += translation.x
        self.center.y += translation.y
        
        sender.setTranslation(CGPoint.zero, in: self)

    }
    
    @IBAction func didPinch(_ sender: UIPinchGestureRecognizer) {
        
        self.superview!.bringSubviewToFront(self)
        
        let scale = sender.scale
        
        self.transform = self.transform.scaledBy(x: scale, y: scale)
        
        sender.scale = 1.0
    }
    
    @IBAction func didRotate(_ sender: UIRotationGestureRecognizer) {

        self.superview!.bringSubviewToFront(self)

        let rotation = sender.rotation

        self.transform = self.transform.rotated(by: rotation)

        sender.rotation = 0.0
    }
    
}
