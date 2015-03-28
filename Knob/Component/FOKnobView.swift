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
    private var pointsCount = 0
    private var pointsData: [CGPoint]!
    
    // MARK: - Init
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor.blueColor()
        
        addPathLayer()
        addHandleLayer()
        addHandleGesture()
        
        createPathPoints()
        
        layoutHandleView()
    }
    
    // MARK: - Path
    
    private func lastPointOfPathElement(element: (UnsafePointer<CGPathElement>)) -> CGPoint? {
        var index: Int?
        let element = element.memory
        
        switch element.type.value {
        case kCGPathElementMoveToPoint.value: index = 0
        case kCGPathElementAddCurveToPoint.value: index = 2
        case kCGPathElementAddLineToPoint.value: index = 0
        case kCGPathElementAddQuadCurveToPoint.value: index = 1
        default: break
        }

        if let index = index {
            return element.points[index]
        }
        return nil
    }
    
    private func createPathPoints() {
        let pattern: [CGFloat] = [1.0, 1.0]
        let dashedPath = CGPathCreateCopyByDashingPath(pathLayer.path, nil, 0.0, pattern, 2)
        let dashedBezierPath = UIBezierPath(CGPath: dashedPath)
        
        var minimumDistance: CGFloat = 0.1
        var priorPoint = CGPointMake(CGFloat(HUGE), CGFloat(HUGE))
        
        pointsData = [CGPoint]()
        dashedBezierPath.forEachElement { (element) -> Void in
            if let point = self.lastPointOfPathElement(element) {
                let value = CGFloat(hypotf(Float(point.x - priorPoint.x), Float(point.y - priorPoint.y)))
                if value < minimumDistance {
                    return
                }
                self.pointsData.append(point)
            } else {
                return
            }
        }
        
        pointsCount = pointsData.count
        if (pointsData.count > 1 && hypotf(Float(pointsData[0].x) - Float(priorPoint.x), Float(pointsData[0].y) - Float(priorPoint.y)) < Float(minimumDistance)) {
            pointsCount -= 1;
        }
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
    
    // MARK: - Layout
    
    private func layoutHandleView() {
        handleView.center = pathLayer.convertPoint(pointsData[handlePathIndex], toLayer: layer)
    }
    
    // MARK: - Gestures
    
    private func addHandleGesture() {
        handleGesture = UIPanGestureRecognizer(target: self, action: "handleDidPan:")
        handleView.addGestureRecognizer(handleGesture)
    }
    
    func handleDidPan(gesture: UIPanGestureRecognizer) {
    }
    
}