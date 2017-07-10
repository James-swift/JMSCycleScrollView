//
//  UIView+JMExtension.swift
//  JMSCycleScrollView
//
//  Created by James.xiao on 2017/7/4.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

extension UIView {
    
    var jms_x: CGFloat {
        set {
            var temp = self.frame
            temp.origin.x = newValue
            self.frame = temp
        }
        get {
            return self.frame.origin.x
        }
    }
    
    var jms_y: CGFloat {
        set {
            var temp = self.frame
            temp.origin.y = newValue
            self.frame = temp
        }
        get {
            return self.frame.origin.y
        }
    }
    
    var jms_width: CGFloat {
        set {
            var temp = self.frame
            temp.size.width = newValue
            self.frame = temp
        }
        get {
            return self.frame.width
        }
    }
    
    var jms_height: CGFloat {
        set {
            var temp = self.frame
            temp.size.height = newValue
            self.frame = temp
        }
        get {
            return self.frame.height
        }
    }
    
}
