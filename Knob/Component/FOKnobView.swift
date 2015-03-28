//
//  FOKnobView.swift
//  Knob
//
//  Created by Jelle Vandenbeeck on 28/03/15.
//  Copyright (c) 2015 Jelle Vandenbeeck. All rights reserved.
//

import UIKit

class FOKnobView: UIView {
    
    // MARK: - Privates
    
    private var pathLayer: CAShapeLayer!
    private var handleLayer: CAShapeLayer!
    
    private var handleView: UIView!
    private var handleGesture: UIGestureRecognizer!
    
    private var handlePathIndex = 0
    
    // MARK: - Init
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor.blueColor()
        
        addPathLayer()
        addHandleLayer()
        addHandleGesture()
    }
    
    // MARK: - Layers
    
    private func addPathLayer() {
        pathLayer = CAShapeLayer()
        pathLayer.lineWidth = 3.0
        pathLayer.fillColor = nil
        pathLayer.strokeColor = UIColor.redColor().CGColor
        pathLayer.lineCap = kCALineCapButt
        pathLayer.lineJoin = kCALineJoinRound
        
        let path = UIBezierPath()
        
        let center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        let padding = CGFloat(10.0)
        let radius = CGRectGetHeight(bounds) / 2.0 - padding
        let startAngle = CGFloat(-M_PI / 1.5)
        let endAngle = CGFloat(-M_PI / 3.0)
        
        path.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        pathLayer.path = path.CGPath
        
        layer.addSublayer(pathLayer)
    }
    
    private func addHandleLayer() {
        handleLayer = CAShapeLayer()
        handleLayer.fillColor = UIColor.greenColor().CGColor
        
        let rect = CGRectMake(0.0, 0.0, 20.0, 20.0)
        handleLayer.path = UIBezierPath(ovalInRect: rect).CGPath
        handleLayer.frame = rect
        
        handleView = UIView(frame: rect)
        handleView.layer.addSublayer(handleLayer)
        addSubview(handleView)
    }
    
    // MARK: - Gestures
    
    private func addHandleGesture() {
        handleGesture = UIPanGestureRecognizer(target: self, action: "handleDidPan:")
        handleView.addGestureRecognizer(handleGesture)
    }
    
    func handleDidPan(gesture: UIPanGestureRecognizer) {
        
    }
    
}