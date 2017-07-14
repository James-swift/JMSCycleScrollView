//
//  JMSDotView.swift
//  JMSPageControl
//
//  Created by James.xiao on 2017/7/4.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

public class JMSDotView: JMSAbstractDotView {
    
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
    }
    
    override public func changeActivityState(active: Bool) {
        if active {
            self.backgroundColor = .white
        }else {
            self.backgroundColor = .clear
        }
    }
    
    // MARK: - UI
    private func setupViews() {
        self.backgroundColor = .clear
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 2
    }

}
