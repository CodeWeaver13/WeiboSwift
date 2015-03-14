//
//  PhotoBrowserController.swift
//  WeiboSwift
//
//  Created by wangshiyu13 on 15/3/9.
//  Copyright (c) 2015年 wangshiyu13. All rights reserved.
//

import UIKit

class PhotoBrowserController: UIViewController {
    /// 图片的URL数组
    var urls: [String]?
    /// 选中图片的索引
    var selectedIndex: Int = 0
    
    @IBOutlet weak var photoView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    class func photoBrowserController()-> PhotoBrowserController {
        let sb = UIStoryboard(name: "PhotoBrowser", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! PhotoBrowserController
        return vc
    }
    ///  MARK: 生命周期方法
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillLayoutSubviews() {
        layout.itemSize = view.bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        photoView.pagingEnabled = true
    }
    override func viewDidLayoutSubviews() {
        let indexPath = NSIndexPath(forItem: selectedIndex, inSection: 0)
        photoView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: false)
    }
    
    ///  关闭按钮点击事件
    @IBAction func exit() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func saveImage(sender: AnyObject) {
        if let indexPath = photoView.indexPathsForVisibleItems().last as? NSIndexPath {
            let cell = photoView.cellForItemAtIndexPath(indexPath) as! PhotoCell
            if let image = cell.imageView?.image {
                UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
            }
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if error != nil {
            SVProgressHUD.showInfoWithStatus("保存失败！")
        } else {
            SVProgressHUD.showInfoWithStatus("保存成功")
        }
    }
}

///  UICollectionView的数据元方法
extension PhotoBrowserController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: PhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        cell.backgroundColor = UIColor(red: random(), green: random(), blue: random(), alpha: random())
        cell.urlStr = urls![indexPath.item]
        return cell
    }
    func random() -> CGFloat {
        return CGFloat(arc4random_uniform(256)) / 255
    }
}

class PhotoCell: UICollectionViewCell, UIScrollViewDelegate {
    var scrollView: UIScrollView?
    var imageView: UIImageView?
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView!
    }
    
    var urlStr: String? {
        didSet {
            let net = NetManager.sharedManager
            net.requestImage(urlStr!) { (result, error) -> () in
                if var image = result as? UIImage {
                    self.setImage(image)
                }
            }
        }
    }
    
    var isShortImage = false
    ///  计算image的大小
    ///
    ///  :param: size image的尺寸
    func setImage(image: UIImage) {
        scrollView?.contentOffset = CGPointZero
        scrollView?.contentSize = CGSizeZero
        scrollView?.contentInset = UIEdgeInsetsZero
        
        let imgSize = image.size
        let screenSize = self.bounds.size
        let h = screenSize.width / imgSize.width * imgSize.height
        let rect = CGRectMake(0, 0, screenSize.width, h)
        
        imageView!.frame = rect
        imageView!.image = image
        scrollView!.frame = self.bounds
        
        if rect.size.height > screenSize.height {
            scrollView!.contentSize = rect.size
            isShortImage = false
        } else {
            scrollView?.contentInset = UIEdgeInsetsMake((screenSize.height - h) * 0.5, 0, 0, 0)
            isShortImage = true
        }
    }
    
    ///  将短图片居中显示
    ///
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
        if isShortImage {
            let y = (frame.size.height - imageView!.frame.size.height) * 0.5
            scrollView.contentInset = UIEdgeInsetsMake(y, 0, 0, 0)
        }
    }
    
    override func awakeFromNib() {
        scrollView = UIScrollView()
        self.addSubview(scrollView!)
        scrollView!.delegate = self
        scrollView!.maximumZoomScale = 2.0
        scrollView!.minimumZoomScale = 1
        imageView = UIImageView()
        scrollView!.addSubview(imageView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView!.frame = self.bounds
    }
}
