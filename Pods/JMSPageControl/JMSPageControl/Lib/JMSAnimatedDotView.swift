//
//  JMSAnimatedDotView.swift
//  JMSPageControl
//
//  Created by James.xiao on 2017/7/4.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

private let kAnimateDuration: TimeInterval = 1

public class JMSAnimatedDotView: JMSAbstractDotView {
    
    public var dotColor: UIColor = .white {
        didSet {
            self.layer.borderColor = dotColor.cgColor
        }
    }

    public override init() {
        super.init()
        self.setupViews()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    override public func changeActivityState(active: Bool) {
        if active {
            self.animateToActiveState()
        }else {
            self.animateToDeactiveState()
        }
    }
    
    // MARK: - UI
    private func setupViews() {
        self.backgroundColor = .clear
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderColor = dotColor.cgColor
        self.layer.borderWidth = 2
    }
    
    // MARK: - Change State
    private func animateToActiveState() {
        UIView.animate(withDuration: kAnimateDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: -20, options: .curveLinear, animations: {
            self.backgroundColor = self.dotColor
            self.transform = CGAffineTransform.init(scaleX: 1.4, y: 1.4)
        }, completion: nil)
    }
    
    private func animateToDeactiveState() {
        UIView.animate(withDuration: kAnimateDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.backgroundColor = .clear
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
}
