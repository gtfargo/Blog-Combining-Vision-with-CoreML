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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.reset()
    }
    
    func setYellowCenterFrame(_ frame: CGRect) {
        let newOriginX = frame.origin.x - floor(frame.size.width / 2)
        let newOriginY = frame.origin.y - floor(frame.size.height / 2)
        let newOrigin = CGPoint(x: newOriginX, y: newOriginY)
        let newFrame = CGRect(origin: newOrigin, size: frame.size)
        
        self.yellowTopConstraint?.constant = newFrame.origin.y
        self.yellowLeadingConstraint?.constant = newFrame.origin.x
        self.yellowHeightConstraint?.constant = newFrame.size.height
        self.yellowWidthConstraint?.constant = newFrame.size.width
    }
    
    func setRedCenterFrame(_ frame: CGRect) {
        let newOriginX = frame.origin.x - floor(frame.size.width / 2)
        let newOriginY = frame.origin.y - floor(frame.size.height / 2)
        let newOrigin = CGPoint(x: newOriginX, y: newOriginY)
        let newFrame = CGRect(origin: newOrigin, size: frame.size)
        
        self.redTopConstraint?.constant = newFrame.origin.y
        self.redLeadingConstraint?.constant = newFrame.origin.x
        self.redHeightConstraint?.constant = newFrame.size.height
        self.redWidthConstraint?.constant = newFrame.size.width
    }
    
    func reset() {
        self.setYellowCenterFrame(.zero)
        self.setRedCenterFrame(.zero)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
}
