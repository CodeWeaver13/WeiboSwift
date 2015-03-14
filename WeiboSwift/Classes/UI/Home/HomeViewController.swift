//
//  HomeViewController.swift
//  WeiboSwift
//
//  Created by wangshiyu13 on 15/2/28.
//  Copyright (c) 2015年 wangshiyu13. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {
    /// 微博数据模型
    var weiboData: WeiboData?
    
    /// 行高缓存
    lazy var cellHeightCache: NSCache? = {
        return NSCache()
    }()
    
    lazy var pullView: RefreshView = {
        return RefreshView.refreshView(isLoading: true)
    }()
    
    ///  MARK: 生命周期方法
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPullView()
        loadData()
    }
    
    deinit {
        tableView.removeObserver(pullView, forKeyPath: "contentOffset")
    }
    
    func setupPullView() {
        tableView.tableFooterView = pullView
        
        weak var weakSelf = self
        pullView.addPullOberserver(tableView){
            if let maxId = self.weiboData?.statuses?.last?.id {
                weakSelf?.loadData(maxId - 1)
            }
        }
    }
    
    ///  加载微博数据
    @IBAction func loadData() {
        loadData(0)
    }
    
    func loadData(maxId: Int) {
        refreshControl?.beginRefreshing()
        weak var weakSelf = self
        WeiboData.loadData(maxId: maxId) { (data, error) -> () in
            weakSelf?.refreshControl?.endRefreshing()
            if error != nil {
                SVProgressHUD.showInfoWithStatus("网络不给力，请重试")
                return
            }
            if data != nil {
                if maxId == 0 {
                    weakSelf?.weiboData = data
                    weakSelf?.tableView.reloadData()
                } else {
                    let list = weakSelf!.weiboData!.statuses! + data!.statuses!
                    weakSelf!.weiboData?.statuses = list
                    
                    weakSelf?.tableView.reloadData()
                    weakSelf?.pullView.pullFinished()
                }
            }
        }
    }
}
///  数据源和代理方法
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.weiboData?.statuses?.count ?? 0
    }
    
    ///  根据indexPath返回微博Cell模型和标识符
    func cellInfo(indexPath: NSIndexPath) -> (model: WeiboModel, cellID: String) {
        let model = self.weiboData!.statuses![indexPath.row]
        let cellID = HomeWeiboCell.cellID(model)
        
        return (model, cellID)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 设置cell
        let info = cellInfo(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(info.cellID, forIndexPath: indexPath) as! HomeWeiboCell
        
        // 根据表格的闭包是否被设置来传递点击事件
        if cell.photoDidSelected == nil {
            weak var weakSelf = self
            cell.photoDidSelected = { (model: WeiboModel, photoIndex: Int)-> () in
                let vc = PhotoBrowserController.photoBrowserController()
                vc.urls = model.largeUrls
                vc.selectedIndex = photoIndex
                weakSelf?.presentViewController(vc, animated: true, completion: nil)
            }
        }
        cell.model = info.model
        return cell
    }
    // 处理行高
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let info = cellInfo(indexPath)
        if let h = cellHeightCache?.objectForKey("\(info.model.id)") as? NSNumber {
            return CGFloat(h.floatValue)
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(info.cellID) as! HomeWeiboCell
            let height = cell.cellHeight(info.model)
            cellHeightCache!.setObject(height, forKey: "\(info.model.id)")
            return height
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
}