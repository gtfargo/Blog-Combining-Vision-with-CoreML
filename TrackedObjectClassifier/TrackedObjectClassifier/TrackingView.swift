//
//  TrackingView.swift
//  TrackedObjectClassifier
//
//  Created by Jeffrey Bergier on 6/10/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

class TrackingView: UIView {
    
    @IBOutlet private weak var redTopConstraint: NSLayoutConstraint?
    @IBOutlet private weak var redLeadingConstraint: NSLayoutConstraint?
    @IBOutlet private weak var redHeightConstraint: NSLayoutConstraint?
    @IBOutlet private weak var redWidthConstraint: NSLayoutConstraint?
    
    @IBOutlet private weak var redView: UIView? {
        didSet {
            self.redView?.layer.borderColor = UIColor.red.cgColor
            self.redView?.layer.borderWidth = 4
            self.redView?.backgroundColor = .clear
        }
    }
    
    @IBOutlet private weak var yellowTopConstraint: NSLayoutConstraint?
    @IBOutlet private weak var yellowLeadingConstraint: NSLayoutConstraint?
    @IBOutlet private weak var yellowHeightConstraint: NSLayoutConstraint?
    @IBOutlet private weak var yellowWidthConstraint: NSLayoutConstraint?
    
    @IBOutlet private weak var yellowView: UIView? {
        didSet {
            self.yellowView?.layer.borderColor = UIColor.yellow.cgColor
            self.yellowView?.layer.borderWidth = 2
            self.yellowView?.backgroundColor = .clear
        }
    }
    
    @IBOutlet private weak var yellowViewLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.reset()
    }
    
    func setYellowViewLabelText(_ text: String?) {
        self.yellowViewLabel?.text = text
    }
    
    func setYellowViewFrame(_ frame: CGRect) {
        self.yellowTopConstraint?.constant = frame.origin.y
        self.yellowLeadingConstraint?.constant = frame.origin.x
        self.yellowHeightConstraint?.constant = frame.size.height
        self.yellowWidthConstraint?.constant = frame.size.width
    }
    
    func setRedViewFrame(_ frame: CGRect) {
        self.redTopConstraint?.constant = frame.origin.y
        self.redLeadingConstraint?.constant = frame.origin.x
        self.redHeightConstraint?.constant = frame.size.height
        self.redWidthConstraint?.constant = frame.size.width
    }
    
    func reset() {
        self.setYellowViewFrame(.zero)
        self.setRedViewFrame(.zero)
        self.setYellowViewLabelText(nil)
    }
    
}
