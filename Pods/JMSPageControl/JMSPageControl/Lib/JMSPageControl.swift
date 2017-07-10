//
//  JMSPageControl.swift
//  JMSPageControl
//
//  Created by James.xiao on 2017/7/4.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

public class JMSPageControl: UIControl {
    
    public var didSelectPage: ((_ pageControl: JMSPageControl, _ atIndex: Int) -> ())?

    /// 自定义的圆点视图，默认是JMSAnimatedDotView
    public var dotViewClass: UIView.Type? = JMSAnimatedDotView.self {
        didSet {
            self.resetDotViews()
        }
    }
    
    /// 其他页面的圆点图片对象
    public var dotImage: UIImage? {
        didSet {
            self.dotViewClass = nil
            self.resetDotViews()
        }
    }
    
    /// 当前页面的圆点图片对象
    public var currentDotImage: UIImage? {
        didSet {
            self.dotViewClass = nil
            self.resetDotViews()
        }
    }
    
    /// 圆点size
    public var dotSize: CGSize = CGSize.init(width: 8, height: 8) {
        didSet {
            self.resetDotViews()
        }
    }
    
    /// 圆点color
    public var dotColor: UIColor? {
        didSet {
            self.resetDotViews()
        }
    }
    
    /// 圆点之间的间隔
    public var spacingBetweenDots: CGFloat = 8 {
        didSet {
            self.resetDotViews()
        }
    }
    
    /// 页面数量
    public var numberOfPages: Int = 0 {
        didSet {
            self.resetDotViews()
        }
    }
    
    /// 当前页面索引
    public var currentPage: Int = 0 {
        willSet {
            if self.numberOfPages == 0 || currentPage == newValue {
                return
            }else {
                self.changeActivity(false, currentPage)
                self.changeActivity(true, newValue)
            }
        }
    }
    
    /// 当前页面索引
    public var hidesForSinglePage: Bool = false {
        didSet {
            self.hideForSinglePage()
        }
    }
    
    /// 是否居中显示，默认true
    public var shouldResizeFromCenter: Bool = true
    
    private lazy var dots: Array<UIView> = {
        return []
    }()

    // MARK: - Init
    public init() {
        super.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Overried
    public override func sizeToFit() {
        self.updateFrame(true)
    }
    
    // MARK: - Touch event
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchView = touches.first?.view {
            if touchView != self {
                if let index = self.dots.index(of: touchView) {
                    self.didSelectPage?(self, index)
                }
            }
        }
    }
    
    // MARK: - UI
    private func updateFrame(_ overrideExistingFrame: Bool) {
        let center = self.center
        let requiredSize = self.sizeForNumberOfPages(self.numberOfPages)
        
        if overrideExistingFrame || ((self.frame.width < requiredSize.width || self.frame.height < requiredSize.height) && !overrideExistingFrame) {
            self.frame = CGRect.init(x: self.frame.minX, y: self.frame.minY, width: requiredSize.width, height: requiredSize.height)
            
            if self.shouldResizeFromCenter {
                self.center = center
            }
        }
        
        self.resetDotViews()
    }
    
    private func resetDotViews() {
        for dotView in self.dots {
            dotView.removeFromSuperview()
        }
        
        self.dots.removeAll()
        self.updateDots()
    }
    
    private func updateDots() {
        if self.numberOfPages == 0 {
            return
        }
        
        for i in 0..<self.numberOfPages {
            var dotView: UIView
            
            if i < self.dots.count {
                dotView = self.dots[i]
            }else {
                dotView = self.generateDotView()
            }
            
            self.updateDotFrame(dotView, i)
        }
        
        self.changeActivity(true, self.currentPage)
        
        self.hideForSinglePage()
    }
    
    private func generateDotView() -> UIView {
        var dotView: UIView
        
        if self.dotViewClass != nil {
            dotView = self.dotViewClass!.init(frame: CGRect.init(x: 0, y: 0, width: self.dotSize.width, height: self.dotSize.height))

            if dotView.isKind(of: JMSAnimatedDotView.self) && (self.dotColor != nil) {
                let tempDotView = dotView as! JMSAnimatedDotView
                tempDotView.dotColor = self.dotColor!
            }
        }else {
            dotView = UIImageView.init(image: self.dotImage)
            dotView.frame = CGRect.init(x: 0, y: 0, width: self.dotSize.width, height: self.dotSize.height)
        }
        
        dotView.isUserInteractionEnabled = true

        self.addSubview(dotView)
        self.dots.append(dotView)
        
        return dotView
    }
    
    private func updateDotFrame(_ dotView: UIView, _ index: Int) {
        let x = (self.dotSize.width + self.spacingBetweenDots) * CGFloat(index) + ((self.frame.width - self.sizeForNumberOfPages(self.numberOfPages).width) / 2)
        let y = (self.frame.height - self.dotSize.height) / 2
        
        dotView.frame = CGRect.init(x: x, y: y, width: self.dotSize.width, height: self.dotSize.height)
    }
    
    private func changeActivity(_ active: Bool, _ index: Int) {
        if self.dotViewClass != nil {
            let dotView = self.dots[index]
            if dotView.isKind(of: JMSAbstractDotView.self) {
                let tempDotView = dotView as! JMSAbstractDotView
                tempDotView.changeActivityState(active: active)
            }
        }else {
            if self.dotImage != nil && self.currentDotImage != nil {
                let dotView = self.dots[index] as? UIImageView
                dotView?.image = active ? self.currentDotImage : self.dotImage
            }
        }
    }
    
    private func hideForSinglePage() {
        if self.dots.count == 1 && self.hidesForSinglePage {
            self.isHidden = true
        }else {
            self.isHidden = false
        }
    }
    
    // MARK: - Size
    public func sizeForNumberOfPages(_ pageCount: Int) -> CGSize {
        return CGSize.init(width: (self.dotSize.width + self.spacingBetweenDots) * CGFloat(pageCount) - self.spacingBetweenDots, height: self.dotSize.height)
    }
    
}
