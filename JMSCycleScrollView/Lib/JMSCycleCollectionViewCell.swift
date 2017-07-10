//
//  JMSCycleCollectionViewCell.swift
//  JMSCycleScrollView
//
//  Created by James.xiao on 2017/7/4.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

public class JMSCycleCollectionViewCell: UICollectionViewCell {
    
    private(set) lazy var titleLabel: UILabel = {
        let tempLabel = UILabel()
        tempLabel.isHidden = true
        
        return tempLabel
    }()
    
    private(set) lazy var imageView: UIImageView = {
        let tempImageView = UIImageView()
        
        return tempImageView
    }()
    
    public var title: String = "" {
        didSet {
            self.titleLabel.text = "   " + title
            self.titleLabel.isHidden = false
        }
    }
    
    public var titleLabelTextColor: UIColor = UIColor.black {
        didSet {
            self.titleLabel.textColor = titleLabelTextColor
        }
    }
    
    public var titleLabelTextFont: UIFont = UIFont.systemFont(ofSize: 15.0) {
        didSet {
            self.titleLabel.font = titleLabelTextFont
        }
    }
    
    public var titleLabelBGColor: UIColor = UIColor.clear {
        didSet {
            self.titleLabel.backgroundColor = titleLabelBGColor
        }
    }
    
    public var titleLabelTextAlignment: NSTextAlignment = .left {
        didSet {
            self.titleLabel.textAlignment = titleLabelTextAlignment
        }
    }
    
    public var titleLabelHeight: CGFloat = 30
    
    public var isOnlyDisplayText: Bool = false // 只展示文字轮播
    
    public var hasConfigured: Bool = false 

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }

    // MARK: - UI
    private func setupViews() {
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.titleLabel)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if self.isOnlyDisplayText {
            self.titleLabel.frame = self.bounds
        }else {
            self.imageView.frame = self.bounds
            self.titleLabel.frame = CGRect.init(x: 0, y: self.jms_height - titleLabelHeight, width: self.jms_width, height: titleLabelHeight)
        }
    }

}
