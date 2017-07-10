//
//  JMSAbstractDotView.swift
//  JMSPageControl
//
//  Created by James.xiao on 2017/7/4.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

public class JMSAbstractDotView: UIView {
    
    public init() {
        super.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 改变视图状态
    ///
    /// - Parameters:
    ///     - parameter active: active为true时是当前页面，false不是当前页面
    /// - Returns Void
    public func changeActivityState(active: Bool) {
        fatalError("changeActivityState(active:) has not been implemented")
    }
    
}
