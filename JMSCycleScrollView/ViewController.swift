//
//  ViewController.swift
//  JMSCycleScrollView
//
//  Created by James.xiao on 2017/7/4.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private(set) var localImageNameArray: Array<String> = {
        return ["1.jpg", "2.jpg", "3.jpg"]
    }()
    
    private(set) var networkImageNameArray: Array<String> = {
        return ["http://pic24.nipic.com/20121008/3822951_094451200000_2.jpg", "http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1308/17/c6/24564406_1376704633091.jpg", "http://imgsrc.baidu.com/image/c0%3Dshijue%2C0%2C0%2C245%2C40/sign=efce41b024dda3cc1fe9b06369805374/e1fe9925bc315c609050b3c087b1cb13485477dc.jpg"]
    }()
    
    private(set) var titleArray: Array<String> = {
        return ["文字上下滚动-1", "文字上下滚动-2", "文字上下滚动-3"]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "JMSCycleScrollView"
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.loadLocalImage()
        self.loadNetworkImage()
        self.loadTitleScroll()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - 本地加载
    private func loadLocalImage() {
        let cycleScrollView = JMSCycleScrollView.init(frame: CGRect.init(x: 0, y: 64, width: self.view.bounds.size.width, height: 180))
        cycleScrollView.backgroundColor = .red
        cycleScrollView.localImageNamesGroup = self.localImageNameArray
//        cycleScrollView.scrollDirection = .vertical // 方向
//        cycleScrollView.autoScrollTimeInterval = 3.0 // 轮播时间间隔
        self.view.addSubview(cycleScrollView)
        
        cycleScrollView.didSelectItemBlk = { [weak self] (collectionView, atIndex) in
            print(String.init(format: "Index: %d" , atIndex))
            let xibVC = XibViewController()
            self?.navigationController?.pushViewController(xibVC, animated: true)
        }
    }
    
    // MARK: - 网络加载
    private func loadNetworkImage() {
        let cycleScrollView = JMSCycleScrollView.init(frame: CGRect.init(x: 0, y: 246, width: self.view.bounds.size.width, height: 180))
        cycleScrollView.pageControlStyle = .animated
        cycleScrollView.placeholderImage = UIImage.init(named: "placeholder")
        cycleScrollView.imageURLStringsGroup = self.networkImageNameArray
        
        self.view.addSubview(cycleScrollView)
        
        cycleScrollView.didSelectItemBlk = { [weak self] (collectionView, atIndex) in
            print(String.init(format: "Index: %d" , atIndex))
            let xibVC = XibViewController()
            self?.navigationController?.pushViewController(xibVC, animated: true)
        }
    }

    // MARK: - 文字滚动
    private func loadTitleScroll() {
        let cycleScrollView = JMSCycleScrollView.init(frame: CGRect.init(x: 0, y: 428, width: self.view.bounds.size.width, height: 40))
        cycleScrollView.scrollDirection = .vertical
        cycleScrollView.isOnlyDisplayText = true
        cycleScrollView.titlesGroup = self.titleArray
        cycleScrollView.backgroundColor = .black
        cycleScrollView.disableScrollGesture()
        
        self.view.addSubview(cycleScrollView)
    }
    
}

