//
//  XibViewController.swift
//  JMSCycleScrollView
//
//  Created by James.xiao on 2017/7/10.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

class XibViewController: UIViewController {
    
    @IBOutlet weak var cycleScrollView: JMSCycleScrollView!

    private(set) var localImageNameArray: Array<String> = {
        return ["1.jpg", "2.jpg", "3.jpg"]
    }()
    
    private(set) var networkImageNameArray: Array<String> = {
        return ["http://pic24.nipic.com/20121008/3822951_094451200000_2.jpg", "http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1308/17/c6/24564406_1376704633091.jpg", "http://imgsrc.baidu.com/image/c0%3Dshijue%2C0%2C0%2C245%2C40/sign=efce41b024dda3cc1fe9b06369805374/e1fe9925bc315c609050b3c087b1cb13485477dc.jpg"]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Xib加自定义Cell方式的JMSCycleScrollView"
        self.automaticallyAdjustsScrollViewInsets = false

        self.setupCstCycleScrollView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI
    private func setupCstCycleScrollView() {
        cycleScrollView.localImageNamesGroup = self.localImageNameArray
        cycleScrollView.pageDotImage = UIImage.init(named: "dotInactive")
        cycleScrollView.currentPageDotImage = UIImage.init(named: "dotActive")
        cycleScrollView.pageControlAliment = .right
        
        cycleScrollView.cstCellRegisterBlk = { (collectionView) in
            return CstCollectionViewCell.self
        }
        
        cycleScrollView.cstCellForItemBlk = { (collectionView, cell, forIndex) in
            if let cstCell = cell as? CstCollectionViewCell {
                cstCell.imageView.kf.setImage(with: URL.init(string: self.networkImageNameArray[forIndex]))
            }
        }
        
        cycleScrollView.cstCellNumberOfItems = { (collectionView) in
            return self.localImageNameArray.count
        }
    }

}
