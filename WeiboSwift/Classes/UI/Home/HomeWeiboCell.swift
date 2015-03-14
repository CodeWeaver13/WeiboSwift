//
//  HomeWeiboCell.swift
//  WeiboSwift
//
//  Created by wangshiyu13 on 15/3/7.
//  Copyright (c) 2015年 wangshiyu13. All rights reserved.
//

import UIKit

class HomeWeiboCell: UITableViewCell {
    
    /// 头像
    @IBOutlet weak var iconView: UIImageView!
    /// 认证
    @IBOutlet weak var certView: UIImageView!
    /// 会员
    @IBOutlet weak var memberView: UIImageView!
    /// 姓名
    @IBOutlet weak var nameView: UILabel!
    /// 时间
    @IBOutlet weak var timeView: UILabel!
    /// 来源
    @IBOutlet weak var sourceView: UILabel!
    /// 正文
    @IBOutlet weak var contentTextView: UILabel!
    /// 配图视图
    @IBOutlet weak var picView: UICollectionView!
    /// 配图视图高度
    @IBOutlet weak var picViewHeight: NSLayoutConstraint!
    /// 配图视图宽度
    @IBOutlet weak var picViewWidth: NSLayoutConstraint!
    /// 配图视图布局
    @IBOutlet weak var picViewLayout: UICollectionViewFlowLayout!
    /// 底部视图
    @IBOutlet weak var bottomView: UIView!
    /// 转发微博文本
    @IBOutlet weak var forwardTextView: UILabel!
    
    /// 从模型取数据
    var model: WeiboModel? {
        didSet {
            nameView.text = model!.user!.name
            timeView.text = model!.created_at
            sourceView.text = model!.source
            contentTextView.text = model!.text
            
            if let iconUrl = model?.user?.profile_image_url {
                NetManager.sharedManager.requestImage(iconUrl, { (result, error) -> () in
                    if let image = result as? UIImage {
                        self.iconView.image = image
                    }
                })
            }
            certView.image = model?.user?.verifiedImage
            memberView.image = model?.user?.mbImage
            
            let pSize = calcPicViewSize()
            picViewWidth.constant = pSize.viewSize.width
            picViewHeight.constant = pSize.viewSize.height
            picViewLayout.itemSize = pSize.itemSize
            picView.reloadData()
            
            if model?.retweeted_status != nil {
                forwardTextView.text = model!.retweeted_status!.user!.name! + ":" + model!.retweeted_status!.text!
            }
        }
    }
    
    ///  返回cell的标识符
    class func cellID(model: WeiboModel) -> String {
        if model.retweeted_status != nil {
            return "ForwardCell"
        } else {
            return "HomeCell"
        }
    }
    
    ///  返回微博Cell的行高
    func cellHeight(model: WeiboModel) -> CGFloat {
        self.model = model
        layoutIfNeeded()
        return CGRectGetMaxY(bottomView.frame)
    }
    
    ///  生命周期方法
    override func awakeFromNib() {
        super.awakeFromNib()
        contentTextView.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 30
        forwardTextView?.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 30
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// 图片配选择的闭包
    var photoDidSelected: ((model: WeiboModel, photoIndex: Int)-> ())?
}

extension HomeWeiboCell: UICollectionViewDataSource, UICollectionViewDelegate {
    ///  cell被选中的方法
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.photoDidSelected != nil {
            self.photoDidSelected!(model: model!, photoIndex: indexPath.item)
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.picUrls?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PicCell", forIndexPath: indexPath) as! PicCell
        cell.urlStr = model!.picUrls![indexPath.item].thumbnail_pic
        return cell
    }
    
    func calcPicViewSize() -> (itemSize: CGSize, viewSize: CGSize) {
        let s: CGFloat = 75
        var itemSize = CGSizeMake(s, s)
        var viewSize = CGSizeZero
        
        let count = model?.picUrls?.count ?? 0
        
        if count == 0 {
            return (itemSize, viewSize)
        }
        
        if count == 1 {
            let path = NetManager.sharedManager.fullImgCachePath(model!.picUrls![0].thumbnail_pic!)
            if let image = UIImage(contentsOfFile: path) {
                return (image.size, image.size)
            } else {
                return (itemSize, viewSize)
            }
        }
        
        let m: CGFloat = 5
        if count == 4 {
            viewSize = CGSizeMake(s * 2 + m, s * 2 + m)
        } else {
            let row = (count - 1) / 3
            viewSize = CGSizeMake(3 * s + 2 * m, (CGFloat(row) + 1) * s + CGFloat(row) * m)
        }
        
        return (itemSize, viewSize)
    }
}

class PicCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var urlStr: String? {
        didSet {
            let path = NetManager.sharedManager.fullImgCachePath(urlStr!)
            let image = UIImage(data: NSData(contentsOfFile: path)!)
            imageView.image = image
        }
    }
}