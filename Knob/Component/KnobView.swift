//
//  FOKnobView.swift
//  Knob
//
//  Created by Jelle Vandenbeeck on 28/03/15.
//  Copyright (c) 2015 Jelle Vandenbeeck. All rights reserved.
//

import UIKit

protocol KnobViewDelegate {
    func knobView(view: KnobView, didChangeValue value: Int)
}

class KnobView: UIView {
    
    // MARK: - Privates
    
    private var pathLayer: CAShapeLayer!
    private var handleLayer: CAShapeLayer!
    private var path: UIBezierPath!
    
    private var handleView: UIView!
    private var handleGesture: UIGestureRecognizer!
    
    private var handlePathIndex = 0
    private var pointsCount = 0
    private var pointsData: [CGPoint]!
    private var desiredHandleCenter: CGPoint!
    
    // MARK: - Public
    
    var delegate: KnobViewDelegate?
    var minimumValue: Int = 0
    var maximumValue: Int = 10
    
    // MARK: - Init
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor.blueColor()
        
        addPathLayer()
        addHandleLayer()
        addHandleGesture()
    }
    
    // MARK: - Path
    
    private func createPath() {
        let center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        let padding = CGFloat(10.0)
        let radius = CGRectGetHeight(bounds) / 2.0 - padding
        let startAngle = CGFloat(-M_PI / 1.5)
        let endAngle = CGFloat(-M_PI / 3.0)
        
        path = UIBezierPath()
        path.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
    }
    
    private func createPathPoints() {
        let pattern: [CGFloat] = [1.0, 1.0]
        let dashedPath = CGPathCreateCopyByDashingPath(path.CGPath, nil, 0.0, pattern, 2)
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
    }
    
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
    
    // MARK: - Layers
    
    private func addPathLayer() {
        pathLayer = CAShapeLayer()
        pathLayer.lineWidth = 3.0
        pathLayer.fillColor = nil
        pathLayer.strokeColor = UIColor.redColor().CGColor
        pathLayer.lineCap = kCALineCapButt
        pathLayer.lineJoin = kCALineJoinRound
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
        handlePathIndex = handlePathPointIndex(offset: 0)
        handleView.center = pathLayer.convertPoint(pointsData[handlePathIndex], toLayer: layer)
    }
    
    private func layoutPathLayer() {
        pathLayer.path = path.CGPath
        pathLayer.frame = bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        createPath()
        createPathPoints()
        
        layoutPathLayer()
        layoutHandleView()
    }
    
    // MARK: - Gestures
    
    private func addHandleGesture() {
        handleGesture = UIPanGestureRecognizer(target: self, action: "handleDidPan:")
        handleView.addGestureRecognizer(handleGesture)
    }
    
    func handleDidPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            desiredHandleCenter = handleView.center
        case .Changed, .Ended, .Cancelled:
            let translation = gesture.translationInView(self)
            desiredHandleCenter.x += translation.x
            desiredHandleCenter.y += translation.y
            moveHandle(point: desiredHandleCenter)
        default: break
        }
        gesture.setTranslation(CGPointZero, inView: self)
    }
    
    // MARK: - Value
    
    private func calculateValue() -> Int {
        let value = CGFloat(handlePathIndex) / CGFloat(pointsCount)
        let difference = CGFloat(maximumValue - minimumValue)
        let ratio = difference / CGFloat(100.0)
        return Int(ceil(value * ratio * CGFloat(100.0) + CGFloat(minimumValue)))
    }
    
    // MARK: - Movement

    private func moveHandle(#point: CGPoint) {
        let earlierDistance = distanceTo(point: point, handleMovesByOffset: -1)
        let currentDistance = distanceTo(point: point, handleMovesByOffset: 0)
        let laterDistance = distanceTo(point: point, handleMovesByOffset: 1)
        if currentDistance <= earlierDistance && currentDistance <= laterDistance {
            return
        }
        
        var direction: Int
        var distance: CGFloat
        if earlierDistance < laterDistance {
            direction = -1
            distance = earlierDistance
        } else {
            direction = 1
            distance = laterDistance
        }
        
        var offset = direction
        while true {
            let nextOffset = offset + direction
            let nextDistance = distanceTo(point: point, handleMovesByOffset: nextOffset)
            if nextDistance >= distance {
                break
            }
            distance = nextDistance
            offset = nextOffset
        }
        handlePathIndex += offset

        delegate?.knobView(self, didChangeValue: calculateValue())
        layoutHandleView()
    }
    
    private func distanceTo(#point: CGPoint, handleMovesByOffset offset: Int) -> CGFloat {
        let index = handlePathPointIndex(offset: offset)
        let proposedHandlePoint = pointsData[index]
        return CGFloat(hypotf(Float(point.x - proposedHandlePoint.x), Float(point.y - proposedHandlePoint.y)))
    }
    
    private func handlePathPointIndex(#offset: Int) -> Int {
        var index = handlePathIndex + offset
        while index < 0 {
            index += pointsCount
        }
        while index >= pointsCount {
            index -= pointsCount
        }
        return index
    }
    
}