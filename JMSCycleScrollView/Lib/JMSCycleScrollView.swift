//
//  JMSCycleScrollView.swift
//  JMSCycleScrollView
//
//  Created by James.xiao on 2017/7/4.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit
import JMSPageControl
import Kingfisher

private let kCell_Id = "JMSCycleScrollViewCell"

public enum JMSCycleScrollViewPageContolStyle {
    case classic    // 系统自带经典样式
    case animated   // 动画效果pageControl
    case none       // 不显示pageControl
}

public enum JMSCycleScrollViewPageContolAliment {
    case right
    case center
}

public class JMSCycleScrollView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    /// 点击回调
    public var didSelectItemBlk: ((_ collectionView: UICollectionView, _ atIndex: Int) -> ())?
    
    /// 滚动回调
    public var didEndScrollingItemBlk: ((_ atIndex: Int) -> ())?

    /// 自定义Cell必须调用的block
    public var cstCellRegisterBlk: ((_ collectionView: UICollectionView) -> (Swift.AnyClass?))? {
        didSet {
            self.mainView.register(self.cstCellRegisterBlk?(self.mainView), forCellWithReuseIdentifier: kCell_Id)
        }
    }
    
    public var cstCellForItemBlk: ((_ collectionView: UICollectionView, _ cell: UICollectionViewCell, _ forIndex: Int) -> ())?
    
    public var cstCellNumberOfItems: ((_ collectionView: UICollectionView) -> Int)? {
        didSet {
            let tempRow = self.cstCellNumberOfItems?(self.mainView) ?? 0
            
            var tempArray: Array<String> = []
            
            for _ in 0..<tempRow {
                tempArray.append("")
            }
            
            self.imageURLStringsGroup = tempArray
        }
    }
    
    // MARK: - 数据源
    /// 网络图片url string数
    public var imageURLStringsGroup: Array<Any> = [] {
        didSet {
            var tempArray: Array<String> = []
            
            for obj in imageURLStringsGroup {
                var tempUrlString: String?
                
                if let temp = obj as? String {
                    tempUrlString = temp
                }else if let temp = obj as? URL {
                    tempUrlString = temp.absoluteString
                }
                
                if tempUrlString != nil {
                    tempArray.append(tempUrlString!)
                }
            }
            
            self.imagePathsGroup = tempArray
        }
    }
    
    /// 每张图片对应要显示的文字数组
    public var titlesGroup: Array<String> = [] {
        didSet {
            if self.isOnlyDisplayText {
                var tempArray: Array<String> = []
                
                for _ in self.titlesGroup {
                    tempArray.append("")
                }
                
                self.backgroundColor = .clear
                self.imagePathsGroup = tempArray
            }
        }
    }
    
    /// 本地图片数组
    public var localImageNamesGroup: Array<Any> = [] {
        didSet {
            self.imagePathsGroup = localImageNamesGroup
        }
    }
    
    // MARK: - 滚动控制
    /// 自动滚动间隔时间，默认2s
    public var autoScrollTimeInterval: TimeInterval = 2.0 {
        didSet {
            let temp = self.isAutoScroll
            self.isAutoScroll = temp
        }
    }
    
    /// 是否无限循环，默认true
    public var isInfiniteLoop: Bool = true {
        didSet {
            let temp = self.imagePathsGroup
            self.imagePathsGroup = temp
        }
    }
    
    /// 是否自动滚动,默认true
    public var isAutoScroll: Bool = true {
        willSet {
            self.invalidateTimer()
        }
        didSet {
            if isAutoScroll {
                self.setupTimer()
            }
        }
    }
    
    /// 图片滚动方向，默认为水平滚动
    public var scrollDirection: UICollectionViewScrollDirection = .horizontal {
        didSet {
            self.flowLayout?.scrollDirection = scrollDirection
            
            if self.scrollDirection == .horizontal {
                self.scrollPositon = .centeredHorizontally
            }else {
                self.scrollPositon = .centeredVertically
            }
        }
    }
    
    private var scrollPositon: UICollectionViewScrollPosition = .centeredHorizontally
    
    // MARK: - 自定义样式
    /// 轮播图片的ContentMode，默认为 scaleToFill
    public var bannerImageViewContentMode: UIViewContentMode = .scaleToFill
    
    /// 占位图，用于网络未加载到图片时
    public var placeholderImage: UIImage? {
        didSet {
            if self.backgroundImageView == nil {
                let tempView = UIImageView()
                tempView.contentMode = .scaleAspectFit
                self.insertSubview(tempView, belowSubview: self.mainView)
                
                self.backgroundImageView = tempView
            }
            
            self.backgroundImageView?.image = placeholderImage
        }
    }
    
    /// 是否显示分页控制, 默认 true
    public var isShowPageControl: Bool = true {
        didSet {
            self.pageControl?.isHidden = !isShowPageControl
        }
    }
    
    /// 是否在只有一张图时隐藏pagecontrol，默认为true
    public var isHidesForSinglePage: Bool = true
    
    /// 只展示文字轮播，默认为false
    public var isOnlyDisplayText: Bool = false
    
    /// 点击是否有高亮效果
    public var isDidItemHighlighted: Bool = false
    
    /// pageControl样式，默认为经典样式
    public var pageControlStyle: JMSCycleScrollViewPageContolStyle = .classic {
        didSet {
            self.setupPageControl()
        }
    }
    
    /// 分页控件位置，默认center
    public var pageControlAliment: JMSCycleScrollViewPageContolAliment = .center
    
    /// 分页控件距离轮播图的底部间距（在默认间距基础上）偏移量
    public var pageControlBottomOffset: CGFloat = 0
    
    /// 分页控件距离轮播图的右边间距（在默认间距基础上）偏移量
    public var pageControlRightOffset: CGFloat = 0
    
    /// 分页控件小圆标大小
    public var pageControlDotSize: CGSize = CGSize.init(width: 10, height: 10) {
        didSet {
            self.setupPageControl()
            
            if let tempPageControl = self.pageControl as? JMSPageControl {
                tempPageControl.dotSize = pageControlDotSize
            }
        }
    }
    
    /// 当前分页控件小圆标颜色
    public var currentPageDotColor: UIColor = .white {
        didSet {
            if let tempPageControl = self.pageControl as? UIPageControl {
                tempPageControl.currentPageIndicatorTintColor = currentPageDotColor
            }else if let tempPageControl = self.pageControl as? JMSPageControl {
                tempPageControl.dotColor = currentPageDotColor
            }
        }
    }
    
    /// 其他分页控件小圆标颜色
    public var pageDotColor: UIColor = .lightGray {
        didSet {
            if let tempPageControl = self.pageControl as? UIPageControl {
                tempPageControl.pageIndicatorTintColor = pageDotColor
            }
        }
    }
    
    /// 当前分页控件小圆标图片
    public var currentPageDotImage: UIImage? {
        didSet {
            if self.currentPageDotImage != nil && self.pageControlStyle != .animated {
                self.pageControlStyle = .animated
            }
            
            self.setupCstPageControl(currentPageDotImage, isCurrentPageDot: true)
        }
    }
    
    /// 其他分页控件小圆标图片
    public var pageDotImage: UIImage? {
        didSet {
            if self.pageDotImage != nil && self.pageControlStyle != .animated {
                self.pageControlStyle = .animated
            }
            
            self.setupCstPageControl(pageDotImage, isCurrentPageDot: false)
        }
    }
    
    /// 轮播文字label字体颜色
    public var titleLabelTextColor: UIColor = .white
    
    /// 轮播文字label字体大小
    public var titleLabelTextFont: UIFont = UIFont.systemFont(ofSize: 14.0)
    
    /// 轮播文字label背景颜色
    public var titleLabelBackgroundColor: UIColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
    
    /// 轮播文字label高度
    public var titleLabelHeight: CGFloat = 30
    
    /// 轮播文字label对齐方式
    public var titleLabelTextAlignment: NSTextAlignment = .left
    
    // MARK: - Block回调
    /// 监听点击
    public var clickItemBlk: ((_ currentIndex: Int)->())?
    
    /// 监听滚动
    public var itemDidScrollBlk: ((_ currentIndex: Int)->())?
    
    public var flowLayout: UICollectionViewFlowLayout?
    
    public lazy var mainView: UICollectionView = {
        let temp = UICollectionView.init(frame: self.bounds, collectionViewLayout: self.flowLayout!)
        temp.backgroundColor = .clear
        temp.isPagingEnabled = true
        temp.showsHorizontalScrollIndicator = false
        temp.showsVerticalScrollIndicator = false
        temp.scrollsToTop = false
        temp.delegate = self
        temp.dataSource = self
        temp.register(JMSCycleCollectionViewCell.self, forCellWithReuseIdentifier: kCell_Id)

        return temp
    }()
    
    private var backgroundImageView: UIImageView?

    private weak var pageControl: UIControl?

    private var imagePathsGroup: Array<Any> = [] {
        willSet {
            self.invalidateTimer()
        }
        
        didSet {
            self.totalItemsCount = self.isInfiniteLoop ? self.imagePathsGroup.count * 100 : self.imagePathsGroup.count
            
            if imagePathsGroup.count > 1 {
                self.mainView.isScrollEnabled = true
                let temp = self.isAutoScroll
                self.isAutoScroll = temp
            }else {
                self.mainView.isScrollEnabled = false
                self.isAutoScroll = false
            }
            
            self.setupPageControl()
            self.mainView.reloadData()
        }
    }
    
    private var totalItemsCount: Int = 0
    
    private var currentIndex: Int {
        get {
            if self.mainView.jms_width == 0 || self.mainView.jms_height == 0 {
                return 0
            }
            
            var index: Int = 0
            
            if let tempLayout = self.flowLayout {
                if tempLayout.scrollDirection == .horizontal {
                    index = Int((self.mainView.contentOffset.x + tempLayout.itemSize.width * 0.5) / tempLayout.itemSize.width)
                }else {
                    index = Int((self.mainView.contentOffset.y + tempLayout.itemSize.height * 0.5) / tempLayout.itemSize.height)
                }
            }
            
            return index
        }
    }
    
    private var timer: Timer?

    // MARK: - Init
    public init(frame: CGRect, flowLayout: UICollectionViewFlowLayout? = nil) {
        super.init(frame: frame)
        self.flowLayout = flowLayout
        setupMainViews()
    }
    
    public init(frame: CGRect, placeholderImage: UIImage, flowLayout: UICollectionViewFlowLayout? = nil) {
        super.init(frame: frame)
        self.flowLayout = flowLayout
        setupMainViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupMainViews()
    }
    
    // MARK: - Overried
    deinit {
        
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            self.invalidateTimer()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.flowLayout?.itemSize = self.frame.size
        
        self.mainView.frame = self.bounds
        
        var targetIndex = 0
        if self.mainView.contentOffset.x == 0 && totalItemsCount != 0 {
            if self.isInfiniteLoop {
                targetIndex = Int(CGFloat(self.totalItemsCount) * 0.5)
            }else {
                targetIndex = 0
            }
            
            self.mainView.scrollToItem(at: IndexPath.init(row: targetIndex, section: 0), at: self.scrollPositon, animated: false)
        }
        
        var size: CGSize = CGSize.zero
        
        if let tempPageControl = self.pageControl as? JMSPageControl {
            size = tempPageControl.sizeForNumberOfPages(self.imagePathsGroup.count)
            tempPageControl.sizeToFit()
        }else {
            size = CGSize.init(width: CGFloat(self.imagePathsGroup.count) * self.pageControlDotSize.width * 1.5, height: self.pageControlDotSize.height)
        }
        
        var x = (self.jms_width - size.width) * 0.5
        
        if self.pageControlAliment == .right {
            x = self.mainView.jms_width - size.width - 10
        }
        
        let y = self.mainView.jms_height - size.height - 10
        
        var tempFrame = CGRect.init(x: x, y: y, width: size.width, height: size.height)
        tempFrame.origin.x -= self.pageControlRightOffset
        tempFrame.origin.y -= self.pageControlBottomOffset
        
        self.pageControl?.frame = tempFrame
        self.pageControl?.isHidden = !self.isShowPageControl
        
        self.backgroundImageView?.frame = self.bounds
    }
    
    // MARK: - UI
    private func setupMainViews() {
        self.flowLayout = flowLayout ?? {
            let temp = UICollectionViewFlowLayout()
            temp.minimumLineSpacing = 0
            temp.scrollDirection = .horizontal
            
            return temp
        }()
        
        self.backgroundColor = .lightGray
        self.addSubview(mainView)
    }
    
    private func setupPageControl() {
        if self.pageControl != nil {
            self.pageControl?.removeFromSuperview()
        }
        
        if self.imagePathsGroup.count == 0 || self.isOnlyDisplayText {
            return
        }
        
        if self.imagePathsGroup.count == 1 && self.isHidesForSinglePage {
            return
        }
        
        let indexOnPageControl = self.pageControlIndex(self.currentIndex)
        
        switch self.pageControlStyle {
        case .classic:
            let tempPageControl = UIPageControl()
            tempPageControl.numberOfPages = self.imagePathsGroup.count
            tempPageControl.currentPageIndicatorTintColor = self.currentPageDotColor
            tempPageControl.pageIndicatorTintColor = self.pageDotColor
            tempPageControl.isUserInteractionEnabled = false
            tempPageControl.currentPage = indexOnPageControl
            
            self.addSubview(tempPageControl)
            
            self.pageControl = tempPageControl
        case .animated:
            let tempPageControl = JMSPageControl.init()
            tempPageControl.numberOfPages = self.imagePathsGroup.count
            tempPageControl.dotColor = self.currentPageDotColor
            tempPageControl.isUserInteractionEnabled = false
            tempPageControl.currentPage = indexOnPageControl
            self.addSubview(tempPageControl)
            
            self.pageControl = tempPageControl
            break
        default:
            break
        }
        
        // 重设pageControldot图片
        var temp = currentPageDotImage
        self.currentPageDotImage = temp
        
        temp = pageDotImage
        self.pageDotImage = temp
    }
    
    private func setupCstPageControl(_ image: UIImage?, isCurrentPageDot: Bool) {
        if image == nil || self.pageControl == nil {
            return
        }
        
        if let tempPageControl = self.pageControl as? JMSPageControl {
            if isCurrentPageDot {
                tempPageControl.currentDotImage = image
            }else {
                tempPageControl.dotImage = image
            }
        }
    }
    
    // MARK: - Timer
    private func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: self.autoScrollTimeInterval, target: self, selector: #selector(automaticScroll), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func automaticScroll() {
        if self.totalItemsCount == 0 {
            return
        }
        
        self.scrollToIndex(self.currentIndex + 1)
    }
    
    // MARK: - Public
    /// 解决viewWillAppear时出现时轮播图卡在一半的问题，在控制器viewWillAppear时调用此方法
    ///
    /// - Returns Void
    public func adjustWhenControllerViewWillAppera() {
        let targetIndex = self.currentIndex
        
        if targetIndex < self.totalItemsCount {
            self.mainView.scrollToItem(at: IndexPath.init(row: targetIndex, section: 0), at: self.scrollPositon, animated: false)
        }
    }
    
    /// 滚动手势禁用(文字轮播较实用)
    ///
    /// - Returns Void
    public func disableScrollGesture() {
        self.mainView.canCancelContentTouches = false
        if let tempGestureRecognizers = self.mainView.gestureRecognizers {
            for gesture in tempGestureRecognizers {
                if gesture.isKind(of: UIPanGestureRecognizer.self) {
                    self.mainView.removeGestureRecognizer(gesture)
                }
            }
        }
    }
    
    /// 滚动到指定页面
    ///
    /// - Returns Void
    public func scrollToIndex(_ targetIndex: Int) {
        if targetIndex >= self.totalItemsCount {
            if self.isInfiniteLoop {
                let tempTargetIndex = Int(CGFloat(self.totalItemsCount) * 0.5)
                self.mainView.scrollToItem(at: IndexPath.init(row: tempTargetIndex, section: 0), at: self.scrollPositon, animated: false)
            }
            return
        }
        
        self.mainView.scrollToItem(at: IndexPath.init(row: targetIndex, section: 0), at: self.scrollPositon, animated: true)
    }
    
    /// 刷新数据
    ///
    /// - Returns Void
    public func reloadData() {
        self.mainView.reloadData()
    }
    
    // MARK: - Private
    private func pageControlIndex(_ currentCellIndex: Int) -> Int {
        return currentCellIndex % self.imagePathsGroup.count
    }
    
    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.totalItemsCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_Id, for: indexPath)
        let itemIndex = self.pageControlIndex(indexPath.item)
        
        if let cstBlk = self.cstCellForItemBlk {
            cstBlk(collectionView, cell, itemIndex)
            return cell
        }
        
        let tempCycleCell = cell as! JMSCycleCollectionViewCell
        let imagePath = self.imagePathsGroup[itemIndex]
        
        if !self.isOnlyDisplayText {
            if let tempStr = imagePath as? String {
                if tempStr.hasPrefix("http") {
                    tempCycleCell.imageView.kf.setImage(with: URL.init(string: tempStr))
                }else {
                    tempCycleCell.imageView.image = UIImage.init(named: tempStr)
                }
            }else if let tempImage = imagePath as? UIImage {
                tempCycleCell.imageView.image = tempImage
            }
        }
        
        if self.titlesGroup.count != 0 && itemIndex < self.titlesGroup.count {
            tempCycleCell.title = self.titlesGroup[itemIndex]
        }
        
        if !tempCycleCell.hasConfigured {
            tempCycleCell.titleLabelBGColor = self.titleLabelBackgroundColor
            tempCycleCell.titleLabelHeight = self.titleLabelHeight
            tempCycleCell.titleLabelTextAlignment = self.titleLabelTextAlignment
            tempCycleCell.titleLabelTextColor = self.titleLabelTextColor
            tempCycleCell.titleLabelTextFont = self.titleLabelTextFont
            tempCycleCell.hasConfigured = true
            tempCycleCell.imageView.contentMode = self.bannerImageViewContentMode
            tempCycleCell.clipsToBounds = true
            tempCycleCell.isOnlyDisplayText = self.isOnlyDisplayText
        }
        
        return tempCycleCell
    }
    
    // MARK: - UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        self.didSelectItemBlk?(collectionView, self.pageControlIndex(indexPath.item))
    }
    
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if self.isDidItemHighlighted {
            let cell    = collectionView.cellForItem(at: indexPath)
            cell?.alpha = 0.5
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if self.isDidItemHighlighted {
            let cell    = collectionView.cellForItem(at: indexPath)
            cell?.alpha = 1
        }
    }
    
    // MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.imagePathsGroup.count == 0 {
            return
        }
        
        let indexOnPageControl = self.pageControlIndex(self.currentIndex)
        
        if let tempPageControl = self.pageControl as? JMSPageControl {
            tempPageControl.currentPage = indexOnPageControl
        }else if let tempPageControl = self.pageControl as? UIPageControl {
            tempPageControl.currentPage = indexOnPageControl
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.isAutoScroll {
            self.invalidateTimer()
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.isAutoScroll {
            self.setupTimer()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if self.imagePathsGroup.count == 0 {
            return
        }

        self.didEndScrollingItemBlk?(self.pageControlIndex(self.currentIndex))
    }

}
