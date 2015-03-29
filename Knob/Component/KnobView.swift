//
//  FOKnobView.swift
//  Knob
//
//  Created by Jelle Vandenbeeck on 28/03/15.
//  Copyright (c) 2015 Jelle Vandenbeeck. All rights reserved.
//
// Reference: http://stackoverflow.com/questions/13664615/drag-uiview-around-shape-comprised-of-cgmutablepaths
//

import UIKit

protocol KnobViewDelegate {
    
    // Delegate method is called when the handle is panned over the path
    // and a matching value is calculated.
    func knobView(view: KnobView, didChangeValue value: Int)
    
}

class KnobView: UIView {
    
    // MARK: - Properties
    
    // The padding from the side.
    private var padding = CGFloat(10.0)
    
    // The end andle of the pathLayer. Take into account that the
    // drawing will occur counter clock wise.
    private var startAngle = CGFloat(-M_PI / 1.5)
    
    // The end andle of the pathLayer. Take into account that the
    // drawing will occur counter clock wise.
    private var endAngle = CGFloat(-M_PI / 3.0)
    
    // Layers just for display purposes.
    private var pathLayer: CAShapeLayer!
    private var handleLayer: CAShapeLayer!
    
    // The path that defines how the handle will move.
    private var path: UIBezierPath!
    
    // The view that you can pan around the pathLayer.
    private var handleView: UIView!
    private var handleGesture: UIGestureRecognizer!
    
    // The index that defines where the handle will be positioned.
    private var handlePathIndex = 0
    
    // The points along the path so that we can find the next point more
    // easily and position the handle correctly on the path.
    private var pointsCount = 0
    private var pointsData: [CGPoint]!
    private var desiredHandleCenter: CGPoint!
    
    var delegate: KnobViewDelegate?
    
    // The values defined here will affect the value returned by the delegate.
    // Make sure the minimum is smaller than the maximum.
    var minimumValue: Int = 0
    var maximumValue: Int = 10
    var value: Int {
        return calculateValue()
    }
    
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
        // Color the path that the handle will follow, in this case it will be a red line.
        
        pathLayer = CAShapeLayer()
        pathLayer.lineWidth = 3.0
        pathLayer.fillColor = nil
        pathLayer.strokeColor = UIColor.redColor().CGColor
        pathLayer.lineCap = kCALineCapButt
        pathLayer.lineJoin = kCALineJoinRound
        layer.addSublayer(pathLayer)
    }
    
    private func addHandleLayer() {
        // Color the handle and add the handle layer to the handle view.
        
        handleLayer = CAShapeLayer()
        handleLayer.fillColor = UIColor.greenColor().CGColor
        handleLayer.frame = CGRectMake(0.0, 0.0, 20.0, 20.0)
        handleLayer.path = UIBezierPath(ovalInRect: handleLayer.frame).CGPath
        handleView = UIView(frame: handleLayer.frame)
        handleView.layer.addSublayer(handleLayer)
        addSubview(handleView)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Reset the path and the path point calculation on layoutSubviews.
        createPath()
        createPathPoints()
        
        // Layout both layers to match the new size.
        layoutPathLayer()
        layoutHandleView()
        
        // We call the delegate method because when the size changes, the value changes.
        delegate?.knobView(self, didChangeValue: calculateValue())
    }
    
    private func layoutHandleView() {
        //Get the new handle index path and apply it to the handleView's center.
        handlePathIndex = handlePathPointIndex(offset: 0)
        handleView.center = pathLayer.convertPoint(pointsData[handlePathIndex], toLayer: layer)
    }
    
    private func layoutPathLayer() {
        // Correct the pathLayer's frame.
        pathLayer.path = path.CGPath
        pathLayer.frame = bounds
    }
    
    // MARK: - Path
    
    private func createPath() {
        // Calculate the center and the radius depending on the settings.
        let center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        let radius = CGRectGetHeight(bounds) / 2.0 - padding
        
        // Draw the curcular path.
        path = UIBezierPath()
        path.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
    }
    
    private func createPathPoints() {
        // We create a dashed copy of the current path.
        let pattern: [CGFloat] = [1.0, 1.0]
        let dashedPath = CGPathCreateCopyByDashingPath(path.CGPath, nil, 0.0, pattern, 2)
        let dashedBezierPath = UIBezierPath(CGPath: dashedPath)
        
        // We want to eliminate all the points that are laying to close agains each other. Therfore
        // we need to define a minimum distance.
        var minimumDistance: CGFloat = 0.1
        
        // This it the previous point value when we iterate the path's elements below.
        var priorPoint = CGPointMake(CGFloat(HUGE), CGFloat(HUGE))
        
        pointsData = [CGPoint]()
        dashedBezierPath.forEachElement { (element) -> Void in
            // Iterate each element and we should receive a value when the element is not
            // a close path element.
            if let point = self.lastPointOfPathElement(element) {
                // If the value is to close the the prior point we discart it. This is defined
                // by the minimum distance.
                let value = CGFloat(hypotf(Float(point.x - priorPoint.x), Float(point.y - priorPoint.y)))
                if value < minimumDistance {
                    return
                }
                // When the value is larger than the minimum distance we add it to the data points.
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
        
        // We set the index value depening on the type of element.
        switch element.type.value {
        case kCGPathElementMoveToPoint.value: index = 0
        case kCGPathElementAddCurveToPoint.value: index = 2
        case kCGPathElementAddLineToPoint.value: index = 0
        case kCGPathElementAddQuadCurveToPoint.value: index = 1
        default: break
        }
        
        if let index = index {
            // When an index is set we fetch the point at a certain index.
            return element.points[index]
        }
        
        // When it's a closed path element no index is set and we will return nil.
        return nil
    }
    
    // MARK: - Gestures
    
    private func addHandleGesture() {
        // The gesture is set on the handle so that we can move the handle.
        handleGesture = UIPanGestureRecognizer(target: self, action: "handleDidPan:")
        handleView.addGestureRecognizer(handleGesture)
    }
    
    func handleDidPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            // When starting to pan we need to get the handle's current
            // center position in order to start from the correct location.
            desiredHandleCenter = handleView.center
        case .Changed, .Ended, .Cancelled:
            // We apply the translation of the handle to the desired center.
            let translation = gesture.translationInView(self)
            desiredHandleCenter.x += translation.x
            desiredHandleCenter.y += translation.y
            
            // Move the handle.
            moveHandle(point: desiredHandleCenter)
        default: break
        }
        gesture.setTranslation(CGPointZero, inView: self)
    }
    
    // MARK: - Value
    
    private func calculateValue() -> Int {
        // The value is calculated depending on the value of the minimum and maximum
        // values.
        let value = CGFloat(handlePathIndex) / CGFloat(pointsCount)
        let difference = CGFloat(maximumValue - minimumValue)
        let ratio = difference / CGFloat(100.0)
        return Int(ceil(value * ratio * CGFloat(100.0) + CGFloat(minimumValue)))
    }
    
    // MARK: - Movement

    private func moveHandle(#point: CGPoint) {
        // We fetch multiple distances with their indexes in order to define the direction
        // the handle is moving.
        let (earlierIndex, earlierDistance) = distanceTo(point: point, handleMovesByOffset: -1)
        let (currentIndex, currentDistance) = distanceTo(point: point, handleMovesByOffset: 0)
        let (laterIndex, laterDistance) = distanceTo(point: point, handleMovesByOffset: 1)
        
        // When both direction move the handle from the desired point nothing should happen.
        // For example: When you drag the handle to the center of the view we want the handle
        // to move along the path. But then it's possible that the earlier distance is the same
        // as the later distance. Nothing should happen in this case.
        if currentDistance <= earlierDistance && currentDistance <= laterDistance {
            return
        }
        
        var index: Int
        var direction: Int
        var distance: CGFloat
        if earlierDistance < laterDistance {
            // we set the values for for when we move the handle backward.
            index = earlierIndex
            direction = -1
            distance = earlierDistance
        } else {
            // we set the values for for when we move the handle foreward.
            direction = 1
            distance = laterDistance
            index = laterIndex
        }
        
        var offset = direction
        while true {
            // In the above cases we only check for the nearest points, but we want to move
            // as close as possible to the
            // This iteration will try to move the handle as close to the desired point as posible.
            let nextOffset = offset + direction
            let (nextIndex, nextDistance) = distanceTo(point: point, handleMovesByOffset: nextOffset)
            if nextDistance >= distance {
                break
            }
            distance = nextDistance
            index = nextIndex
            offset = nextOffset
        }
        
        handlePathIndex = index
        
        // Call the delegate method because the handle panned.
        delegate?.knobView(self, didChangeValue: value)
        
        // Update the handle's position to the new handle index path.
        layoutHandleView()
    }
    
    private func distanceTo(#point: CGPoint, handleMovesByOffset offset: Int) -> (Int, CGFloat) {
        // Calculate the distance to the point depending on the offset. We return the index of the 
        // proposed point we assume is the closest and the distance from the given point.
        let index = handlePathPointIndex(offset: offset)
        let proposedHandlePoint = pointsData[index]
        let distance = CGFloat(hypotf(Float(point.x - proposedHandlePoint.x), Float(point.y - proposedHandlePoint.y)))
        return (index, distance)
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