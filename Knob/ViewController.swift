//
//  ViewController.swift
//  Knob
//
//  Created by Jelle Vandenbeeck on 28/03/15.
//  Copyright (c) 2015 Jelle Vandenbeeck. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FOKnobViewDelegate {
    
    // MARK: - Properties
    
    @IBOutlet var label: UILabel!
    @IBOutlet var knobView: FOKnobView!
    @IBOutlet var knobHeightConstraint: NSLayoutConstraint!
    
    // MARK: - View flow
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        knobView.delegate = self
    }

    // MARK: - Actions

    @IBAction func tappedKnob(sender: AnyObject) {
        if knobHeightConstraint.constant == 150.0 {
           knobHeightConstraint.constant = 200.0
        } else {
           knobHeightConstraint.constant = 150.0
        }
    }

}

extension ViewController: FOKnobViewDelegate {
    
    func knobView(view: FOKnobView, didChangeValue value: CGFloat) {
        label.text = "\(Int(value * 10))"
    }
    
}