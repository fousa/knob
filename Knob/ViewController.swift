//
//  ViewController.swift
//  Knob
//
//  Created by Jelle Vandenbeeck on 28/03/15.
//  Copyright (c) 2015 Jelle Vandenbeeck. All rights reserved.
//

import UIKit

class ViewController: UIViewController, KnobViewDelegate {
    
    // MARK: - Properties
    
    @IBOutlet var label: UILabel!
    @IBOutlet var knobView: KnobView!
    @IBOutlet var knobHeightConstraint: NSLayoutConstraint!
    
    // MARK: - View flow
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red:0.05, green:0.4, blue:0.6, alpha:1)
        
        knobView.delegate = self
        knobView.layer.cornerRadius = 20.0
        
        knobView.minimumValue = 0
        knobView.maximumValue = 10
    }

    // MARK: - Actions

    @IBAction func tappedKnob(sender: AnyObject) {
        if knobHeightConstraint.constant == 150.0 {
           knobHeightConstraint.constant = 200.0
        } else {
           knobHeightConstraint.constant = 150.0
        }
        knobView.setNeedsLayout()
    }
    
    // MARK: - Status bar
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

}

extension ViewController: KnobViewDelegate {
    
    func knobView(view: KnobView, didChangeValue value: Int) {
        label.text = "\(value)"
    }
    
}