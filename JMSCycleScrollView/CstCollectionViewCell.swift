//
//  CstCollectionViewCell.swift
//  JMSCycleScrollView
//
//  Created by James.xiao on 2017/7/10.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

class CstCollectionViewCell: UICollectionViewCell {
    
    private(set) var imageView: UIImageView = {
        let tempImageView = UIImageView()
        tempImageView.layer.borderColor = UIColor.red.cgColor
        tempImageView.layer.borderWidth = 2
        
        return tempImageView
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    private func setupViews() {
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(self.imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
    }
    
}
