//
//  ViewController.swift
//  Knob
//
//  Created by Jelle Vandenbeeck on 28/03/15.
//  Copyright (c) 2015 Jelle Vandenbeeck. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var knobHeightConstraint: NSLayoutConstraint!

    // MARK: - Actions

    @IBAction func tappedKnob(sender: AnyObject) {
        if knobHeightConstraint.constant == 150.0 {
           knobHeightConstraint.constant = 200.0
        } else {
           knobHeightConstraint.constant = 150.0
        }
    }

}

